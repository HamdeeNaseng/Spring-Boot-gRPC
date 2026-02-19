package com.spring.grpc.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

/**
 * Payment Service Application
 * Consumes Kafka events and processes payments
 */
@SpringBootApplication
@EnableKafka
public class PaymentServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(PaymentServiceApplication.class, args);
        System.out.println("==========================================");
        System.out.println("💳 Payment Service Started Successfully");
        System.out.println("🌐 HTTP Server: Port 8082");
        System.out.println("📨 Kafka Consumer: Listening...");
        System.out.println("==========================================");
    }
}
