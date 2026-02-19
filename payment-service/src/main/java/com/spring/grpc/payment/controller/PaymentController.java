package com.spring.grpc.payment.controller;

import com.spring.grpc.payment.entity.Payment;
import com.spring.grpc.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Payment REST API Controller
 */
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    /**
     * Get payment by order ID
     */
    @GetMapping("/order/{orderId}")
    public ResponseEntity<?> getPaymentByOrderId(@PathVariable String orderId) {
        Optional<Payment> payment = paymentService.getPaymentByOrderId(orderId);
        
        if (payment.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Payment not found for order: " + orderId);
            return ResponseEntity.status(404).body(error);
        }
        
        return ResponseEntity.ok(payment.get());
    }

    /**
     * Get payments by user ID
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Payment>> getPaymentsByUserId(@PathVariable String userId) {
        List<Payment> payments = paymentService.getPaymentsByUserId(userId);
        return ResponseEntity.ok(payments);
    }

    /**
     * Get all payments
     */
    @GetMapping
    public ResponseEntity<List<Payment>> getAllPayments() {
        List<Payment> payments = paymentService.getAllPayments();
        return ResponseEntity.ok(payments);
    }

    /**
     * Get payment statistics
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getPaymentStats() {
        List<Payment> allPayments = paymentService.getAllPayments();
        
        long total = allPayments.size();
        long completed = allPayments.stream().filter(p -> "COMPLETED".equals(p.getStatus())).count();
        long failed = allPayments.stream().filter(p -> "FAILED".equals(p.getStatus())).count();
        long pending = allPayments.stream().filter(p -> "PENDING".equals(p.getStatus())).count();
        long processing = allPayments.stream().filter(p -> "PROCESSING".equals(p.getStatus())).count();
        
        double totalAmount = allPayments.stream()
                .filter(p -> "COMPLETED".equals(p.getStatus()))
                .mapToDouble(Payment::getAmount)
                .sum();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalPayments", total);
        stats.put("completed", completed);
        stats.put("failed", failed);
        stats.put("pending", pending);
        stats.put("processing", processing);
        stats.put("totalAmountProcessed", totalAmount);
        stats.put("successRate", total > 0 ? (double) completed / total * 100 : 0);
        
        return ResponseEntity.ok(stats);
    }
}
