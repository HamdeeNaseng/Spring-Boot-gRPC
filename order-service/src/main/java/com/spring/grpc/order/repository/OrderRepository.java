package com.spring.grpc.order.repository;

import com.spring.grpc.order.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Order Repository
 */
@Repository
public interface OrderRepository extends JpaRepository<Order, String> {

    /**
     * Find orders by user ID with pagination
     */
    Page<Order> findByUserId(String userId, Pageable pageable);

    /**
     * Find order by order ID
     */
    Optional<Order> findByOrderId(String orderId);

    /**
     * Count orders by user ID
     */
    long countByUserId(String userId);

    /**
     * Find orders by status
     */
    Page<Order> findByStatus(String status, Pageable pageable);
}
