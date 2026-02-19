package com.spring.grpc.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

/**
 * Order Service Application
 * Provides gRPC server for order management and produces Kafka events
 */
@SpringBootApplication
@EnableKafka
public class OrderServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
        System.out.println("======================================");
        System.out.println("🚀 Order Service Started Successfully");
        System.out.println("📡 gRPC Server: Port 9090");
        System.out.println("🌐 HTTP Server: Port 8081");
        System.out.println("📨 Kafka Producer: Ready");
        System.out.println("======================================");
    }
}
