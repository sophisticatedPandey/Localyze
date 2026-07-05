package com.localyze.service;

import com.localyze.dto.request.ReviewRequest;
import com.localyze.dto.response.PagedResponse;
import com.localyze.dto.response.ReviewResponse;
import com.localyze.entity.*;
import com.localyze.entity.enums.BookingStatus;
import com.localyze.exception.BadRequestException;
import com.localyze.exception.ResourceNotFoundException;
import com.localyze.exception.UnauthorizedException;
import com.localyze.mapper.ReviewMapper;
import com.localyze.repository.BookingRepository;
import com.localyze.repository.ReviewRepository;
import com.localyze.repository.ServiceRepository;
import com.localyze.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Manages reviews for completed bookings. Enforces one review per booking
 * and automatically recalculates service average ratings on changes.
 */
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookingRepository bookingRepository;
    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;
    private final ReviewMapper reviewMapper;

    /**
     * Creates a review for a completed booking. Each booking can only have one review.
     *
     * @param userEmail the reviewer's email
     * @param request   the review request containing bookingId, rating, and comment
     * @return the created review response
     * @throws UnauthorizedException if the user does not own the booking
     * @throws BadRequestException   if the booking is not completed or already reviewed
     */
    @Transactional
    public ReviewResponse createReview(String userEmail, ReviewRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", userEmail));

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", request.getBookingId()));

        if (!booking.getUser().getEmail().equals(userEmail)) {
            throw new UnauthorizedException("You can only review your own bookings");
        }

        if (booking.getStatus() != BookingStatus.COMPLETED) {
            throw new BadRequestException("You can only review completed bookings");
        }

        if (reviewRepository.existsByBookingId(booking.getId())) {
            throw new BadRequestException("You have already reviewed this booking");
        }

        Review review = Review.builder()
                .user(user)
                .service(booking.getService())
                .booking(booking)
                .rating(request.getRating())
                .comment(request.getComment())
                .isDeleted(false)
                .build();

        review = reviewRepository.save(review);

        // Update service average rating
        updateServiceRating(booking.getService().getId());

        return reviewMapper.toResponse(review);
    }

    /**
     * Retrieves paginated reviews for a specific service.
     *
     * @param serviceId the service ID
     * @param page      page number (0-based)
     * @param size      page size
     * @return paginated review responses
     */
    public PagedResponse<ReviewResponse> getServiceReviews(Long serviceId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Review> reviewPage = reviewRepository.findByServiceIdAndIsDeletedFalse(serviceId, pageable);

        List<ReviewResponse> content = reviewPage.getContent().stream()
                .map(reviewMapper::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.<ReviewResponse>builder()
                .content(content)
                .page(reviewPage.getNumber())
                .size(reviewPage.getSize())
                .totalElements(reviewPage.getTotalElements())
                .totalPages(reviewPage.getTotalPages())
                .last(reviewPage.isLast())
                .build();
    }

    /**
     * Updates a review's rating and/or comment. Only the review author can edit.
     *
     * @param id        the review ID
     * @param userEmail the authenticated user's email
     * @param rating    the new rating (nullable)
     * @param comment   the new comment (nullable)
     * @return the updated review response
     * @throws UnauthorizedException if the user does not own the review
     */
    @Transactional
    public ReviewResponse updateReview(Long id, String userEmail, Integer rating, String comment) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review", "id", id));

        if (!review.getUser().getEmail().equals(userEmail)) {
            throw new UnauthorizedException("You can only edit your own reviews");
        }

        if (rating != null) review.setRating(rating);
        if (comment != null) review.setComment(comment);

        review = reviewRepository.save(review);
        updateServiceRating(review.getService().getId());

        return reviewMapper.toResponse(review);
    }

    /**
     * Soft-deletes a review. Only the review author can delete.
     * Recalculates the service's average rating after deletion.
     *
     * @param id        the review ID
     * @param userEmail the authenticated user's email
     * @throws UnauthorizedException if the user does not own the review
     */
    @Transactional
    public void deleteReview(Long id, String userEmail) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review", "id", id));

        if (!review.getUser().getEmail().equals(userEmail)) {
            throw new UnauthorizedException("You can only delete your own reviews");
        }

        review.setDeleted(true);
        reviewRepository.save(review);
        updateServiceRating(review.getService().getId());
    }

    /**
     * Recalculates and persists the average rating and total review count
     * for the given service based on all non-deleted reviews.
     */
    private void updateServiceRating(Long serviceId) {
        ServiceEntity service = serviceRepository.findById(serviceId).orElse(null);
        if (service == null) return;

        List<Review> reviews = reviewRepository.findByServiceIdAndIsDeletedFalse(serviceId, Pageable.unpaged()).getContent();
        if (reviews.isEmpty()) {
            service.setAvgRating(0.0);
            service.setTotalReviews(0);
        } else {
            double avg = reviews.stream().mapToInt(Review::getRating).average().orElse(0.0);
            service.setAvgRating(Math.round(avg * 10.0) / 10.0);
            service.setTotalReviews(reviews.size());
        }
        serviceRepository.save(service);
    }
}
