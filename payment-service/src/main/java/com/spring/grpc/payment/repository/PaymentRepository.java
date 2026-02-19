package com.spring.grpc.payment.repository;

import com.spring.grpc.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Payment Repository
 */
@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {

    /**
     * Find payment by order ID
     */
    Optional<Payment> findByOrderId(String orderId);

    /**
     * Find payments by user ID
     */
    List<Payment> findByUserId(String userId);

    /**
     * Find payments by status
     */
    List<Payment> findByStatus(String status);

    /**
     * Check if payment exists for order
     */
    boolean existsByOrderId(String orderId);
}
