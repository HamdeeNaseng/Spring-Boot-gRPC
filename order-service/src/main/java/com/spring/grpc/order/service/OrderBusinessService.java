package com.spring.grpc.order.service;

import com.spring.grpc.order.dto.OrderEvent;
import com.spring.grpc.order.entity.Order;
import com.spring.grpc.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Order Business Service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderBusinessService {

    private final OrderRepository orderRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${kafka.topics.order-created}")
    private String orderCreatedTopic;

    @Value("${kafka.topics.order-updated}")
    private String orderUpdatedTopic;

    /**
     * Create new order and publish event
     */
    @Transactional
    public Order createOrder(String userId, String productId, String productName, 
                            Integer quantity, Double price) {
        // Calculate total amount
        Double totalAmount = quantity * price;

        // Create order entity
        Order order = Order.builder()
                .userId(userId)
                .productId(productId)
                .productName(productName)
                .quantity(quantity)
                .price(price)
                .totalAmount(totalAmount)
                .status("PENDING")
                .build();

        // Save to database
        Order savedOrder = orderRepository.save(order);
        log.info("Order created successfully: {}", savedOrder.getOrderId());

        // Publish Kafka event
        publishOrderCreatedEvent(savedOrder);

        return savedOrder;
    }

    /**
     * Get order by ID
     */
    public Optional<Order> getOrderById(String orderId) {
        return orderRepository.findByOrderId(orderId);
    }

    /**
     * List orders with pagination
     */
    public Page<Order> listOrders(int page, int size, String userId) {
        PageRequest pageRequest = PageRequest.of(page, size);
        
        if (userId != null && !userId.isEmpty()) {
            return orderRepository.findByUserId(userId, pageRequest);
        }
        
        return orderRepository.findAll(pageRequest);
    }

    /**
     * Update order status
     */
    @Transactional
    public Order updateOrderStatus(String orderId, String newStatus) {
        Optional<Order> orderOpt = orderRepository.findByOrderId(orderId);
        
        if (orderOpt.isEmpty()) {
            throw new RuntimeException("Order not found: " + orderId);
        }

        Order order = orderOpt.get();
        String oldStatus = order.getStatus();
        order.setStatus(newStatus);
        
        Order updatedOrder = orderRepository.save(order);
        log.info("Order status updated: {} -> {}", oldStatus, newStatus);

        // Publish update event
        publishOrderUpdatedEvent(updatedOrder);

        return updatedOrder;
    }

    /**
     * Publish order created event to Kafka
     */
    private void publishOrderCreatedEvent(Order order) {
        OrderEvent event = OrderEvent.builder()
                .orderId(order.getOrderId())
                .userId(order.getUserId())
                .productId(order.getProductId())
                .productName(order.getProductName())
                .quantity(order.getQuantity())
                .price(order.getPrice())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus())
                .createdAt(order.getCreatedAt())
                .eventType("CREATED")
                .build();

        kafkaTemplate.send(orderCreatedTopic, order.getOrderId(), event);
        log.info("Published order created event to Kafka: {}", order.getOrderId());
    }

    /**
     * Publish order updated event to Kafka
     */
    private void publishOrderUpdatedEvent(Order order) {
        OrderEvent event = OrderEvent.builder()
                .orderId(order.getOrderId())
                .userId(order.getUserId())
                .productId(order.getProductId())
                .productName(order.getProductName())
                .quantity(order.getQuantity())
                .price(order.getPrice())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus())
                .createdAt(order.getCreatedAt())
                .eventType("UPDATED")
                .build();

        kafkaTemplate.send(orderUpdatedTopic, order.getOrderId(), event);
        log.info("Published order updated event to Kafka: {}", order.getOrderId());
    }
}
