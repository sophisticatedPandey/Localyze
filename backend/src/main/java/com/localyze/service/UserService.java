package com.localyze.service;

import com.localyze.dto.request.ChangePasswordRequest;
import com.localyze.dto.request.UpdateProfileRequest;
import com.localyze.dto.response.UserResponse;
import com.localyze.entity.User;
import com.localyze.exception.BadRequestException;
import com.localyze.exception.ResourceNotFoundException;
import com.localyze.mapper.UserMapper;
import com.localyze.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Manages user profile operations including retrieval, updates,
 * password changes, location updates, and account deactivation.
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    /**
     * Retrieves the current user's profile by email.
     *
     * @param email the authenticated user's email
     * @return the user profile response
     */
    public UserResponse getCurrentUser(String email) {
        User user = findByEmail(email);
        return userMapper.toResponse(user);
    }

    /**
     * Updates the user's profile with the provided fields.
     * Only non-null fields in the request are updated.
     *
     * @param email   the authenticated user's email
     * @param request the update profile request
     * @return the updated user profile response
     * @throws BadRequestException if the new phone number is already in use
     */
    @Transactional
    public UserResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = findByEmail(email);
        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getPhone() != null) {
            if (userRepository.existsByPhone(request.getPhone()) && !request.getPhone().equals(user.getPhone())) {
                throw new BadRequestException("Phone number already in use");
            }
            user.setPhone(request.getPhone());
        }
        if (request.getAddress() != null) user.setAddress(request.getAddress());
        if (request.getLatitude() != null) user.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) user.setLongitude(request.getLongitude());
        if (request.getProfileImageUrl() != null) user.setProfileImageUrl(request.getProfileImageUrl());
        return userMapper.toResponse(userRepository.save(user));
    }

    /**
     * Changes the user's password after verifying the current password.
     *
     * @param email   the authenticated user's email
     * @param request the change password request
     * @throws BadRequestException if the current password is incorrect
     */
    @Transactional
    public void changePassword(String email, ChangePasswordRequest request) {
        User user = findByEmail(email);
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new BadRequestException("Current password is incorrect");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    /**
     * Updates the user's geographic location.
     *
     * @param email     the authenticated user's email
     * @param latitude  the new latitude
     * @param longitude the new longitude
     */
    @Transactional
    public void updateLocation(String email, Double latitude, Double longitude) {
        User user = findByEmail(email);
        user.setLatitude(latitude);
        user.setLongitude(longitude);
        userRepository.save(user);
    }

    /**
     * Soft-deactivates the user's account.
     *
     * @param email the authenticated user's email
     */
    @Transactional
    public void deactivateAccount(String email) {
        User user = findByEmail(email);
        user.setActive(false);
        userRepository.save(user);
    }

    /**
     * Finds a user by email or throws ResourceNotFoundException.
     */
    private User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }
}
