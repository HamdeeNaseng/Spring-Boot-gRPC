package com.spring.grpc.payment.service;

import com.spring.grpc.payment.entity.Payment;
import com.spring.grpc.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Payment Business Service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentRepository paymentRepository;

    /**
     * Create payment for order
     */
    @Transactional
    public Payment createPayment(String orderId, String userId, Double amount) {
        // Check if payment already exists
        if (paymentRepository.existsByOrderId(orderId)) {
            log.warn("Payment already exists for order: {}", orderId);
            return paymentRepository.findByOrderId(orderId).orElseThrow();
        }

        // Create payment entity
        Payment payment = Payment.builder()
                .orderId(orderId)
                .userId(userId)
                .amount(amount)
                .status("PENDING")
                .paymentMethod("AUTO")
                .build();

        Payment savedPayment = paymentRepository.save(payment);
        log.info("Payment created: {} for order: {}", savedPayment.getPaymentId(), orderId);

        return savedPayment;
    }

    /**
     * Process payment (simulate payment processing)
     */
    @Transactional
    public Payment processPayment(String orderId) {
        Optional<Payment> paymentOpt = paymentRepository.findByOrderId(orderId);
        
        if (paymentOpt.isEmpty()) {
            throw new RuntimeException("Payment not found for order: " + orderId);
        }

        Payment payment = paymentOpt.get();
        
        if (!"PENDING".equals(payment.getStatus())) {
            log.warn("Payment already processed: {}", payment.getPaymentId());
            return payment;
        }

        // Update status to PROCESSING
        payment.setStatus("PROCESSING");
        paymentRepository.save(payment);
        log.info("Payment processing started: {}", payment.getPaymentId());

        // Simulate payment processing
        try {
            // In real scenario, this would call payment gateway API
            Thread.sleep(1000); // Simulate processing time
            
            // Success scenario (90% success rate simulation)
            if (Math.random() > 0.1) {
                payment.setStatus("COMPLETED");
                payment.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 8));
                log.info("Payment completed successfully: {}", payment.getPaymentId());
            } else {
                // Failure scenario
                payment.setStatus("FAILED");
                payment.setErrorMessage("Insufficient funds or payment gateway error");
                log.error("Payment failed: {}", payment.getPaymentId());
            }
            
            return paymentRepository.save(payment);
            
        } catch (Exception e) {
            payment.setStatus("FAILED");
            payment.setErrorMessage(e.getMessage());
            paymentRepository.save(payment);
            log.error("Payment processing error: {}", e.getMessage());
            throw new RuntimeException("Payment processing failed", e);
        }
    }

    /**
     * Get payment by order ID
     */
    public Optional<Payment> getPaymentByOrderId(String orderId) {
        return paymentRepository.findByOrderId(orderId);
    }

    /**
     * Get payments by user ID
     */
    public List<Payment> getPaymentsByUserId(String userId) {
        return paymentRepository.findByUserId(userId);
    }

    /**
     * Get all payments
     */
    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }
}
