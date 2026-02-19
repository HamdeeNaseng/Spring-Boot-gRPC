package com.spring.grpc.payment.consumer;

import com.spring.grpc.payment.dto.OrderEvent;
import com.spring.grpc.payment.entity.Payment;
import com.spring.grpc.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Kafka Consumer for Order Events
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OrderEventConsumer {

    private final PaymentService paymentService;

    /**
     * Listen to order.created topic
     */
    @KafkaListener(
            topics = "${kafka.topics.order-created}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void handleOrderCreated(OrderEvent orderEvent) {
        try {
            log.info("======================================");
            log.info("📨 Received Order Created Event");
            log.info("Order ID: {}", orderEvent.getOrderId());
            log.info("User ID: {}", orderEvent.getUserId());
            log.info("Product: {}", orderEvent.getProductName());
            log.info("Amount: ${}", orderEvent.getTotalAmount());
            log.info("======================================");

            // Create payment record
            Payment payment = paymentService.createPayment(
                    orderEvent.getOrderId(),
                    orderEvent.getUserId(),
                    orderEvent.getTotalAmount()
            );

            log.info("💳 Payment record created: {}", payment.getPaymentId());

            // Process payment asynchronously (in real scenario, this might be in a separate thread)
            processPaymentAsync(orderEvent.getOrderId());

        } catch (Exception e) {
            log.error("❌ Error processing order created event: {}", e.getMessage(), e);
        }
    }

    /**
     * Listen to order.updated topic
     */
    @KafkaListener(
            topics = "${kafka.topics.order-updated}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void handleOrderUpdated(OrderEvent orderEvent) {
        try {
            log.info("======================================");
            log.info("🔄 Received Order Updated Event");
            log.info("Order ID: {}", orderEvent.getOrderId());
            log.info("Status: {}", orderEvent.getStatus());
            log.info("======================================");

            // Handle order status updates
            if ("CANCELLED".equals(orderEvent.getStatus())) {
                log.info("⚠️ Order cancelled, payment processing should be halted");
                // In real scenario: refund or cancel payment
            }

        } catch (Exception e) {
            log.error("❌ Error processing order updated event: {}", e.getMessage(), e);
        }
    }

    /**
     * Process payment asynchronously
     */
    private void processPaymentAsync(String orderId) {
        // In production, this would be submitted to a thread pool or message queue
        new Thread(() -> {
            try {
                Thread.sleep(2000); // Simulate delay before processing
                Payment processedPayment = paymentService.processPayment(orderId);
                
                if ("COMPLETED".equals(processedPayment.getStatus())) {
                    log.info("✅ Payment completed: {}", processedPayment.getPaymentId());
                    log.info("   Transaction ID: {}", processedPayment.getTransactionId());
                } else {
                    log.error("❌ Payment failed: {}", processedPayment.getPaymentId());
                    log.error("   Error: {}", processedPayment.getErrorMessage());
                }
                
            } catch (Exception e) {
                log.error("❌ Error in async payment processing: {}", e.getMessage());
            }
        }).start();
    }
}
