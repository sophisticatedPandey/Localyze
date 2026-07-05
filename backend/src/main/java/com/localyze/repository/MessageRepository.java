package com.localyze.repository;

import com.localyze.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByBookingIdOrderByCreatedAtAsc(Long bookingId);

    long countByReceiverIdAndIsReadFalse(Long receiverId);
}
