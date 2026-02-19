package com.spring.grpc.order.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Order Event DTO for Kafka
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderEvent {
    private String orderId;
    private String userId;
    private String productId;
    private String productName;
    private Integer quantity;
    private Double price;
    private Double totalAmount;
    private String status;
    private LocalDateTime createdAt;
    private String eventType; // CREATED, UPDATED, CANCELLED
}
