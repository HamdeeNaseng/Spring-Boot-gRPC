package com.spring.grpc.order.controller;

import com.spring.grpc.order.dto.CreateOrderRequest;
import com.spring.grpc.order.dto.UpdateOrderStatusRequest;
import com.spring.grpc.order.entity.Order;
import com.spring.grpc.order.repository.OrderRepository;
import com.spring.grpc.order.service.OrderBusinessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * Order REST Controller
 */
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderBusinessService orderBusinessService;
    private final OrderRepository orderRepository;

    /**
     * Create new order
     */
    @PostMapping
    public ResponseEntity<Order> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());
        
        Order order = orderBusinessService.createOrder(
                request.getUserId(),
                request.getProductId(),
                request.getProductName(),
                request.getQuantity(),
                request.getPrice()
        );
        
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }

    /**
     * Get all orders with pagination
     */
    @GetMapping
    public ResponseEntity<List<Order>> getAllOrders(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        log.info("Getting all orders - page: {}, size: {}", page, size);
        Page<Order> ordersPage = orderBusinessService.listOrders(page, size, null);
        return ResponseEntity.ok(ordersPage.getContent());
    }

    /**
     * Get order by ID
     */
    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrderById(@PathVariable String orderId) {
        log.info("Getting order by ID: {}", orderId);
        
        return orderBusinessService.getOrderById(orderId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get orders by user ID
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Order>> getOrdersByUserId(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        log.info("Getting orders for user: {}", userId);
        Page<Order> ordersPage = orderBusinessService.listOrders(page, size, userId);
        return ResponseEntity.ok(ordersPage.getContent());
    }

    /**
     * Get orders by status
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Order>> getOrdersByStatus(
            @PathVariable String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        log.info("Getting orders by status: {}", status);
        PageRequest pageRequest = PageRequest.of(page, size);
        Page<Order> ordersPage = orderRepository.findByStatus(status, pageRequest);
        return ResponseEntity.ok(ordersPage.getContent());
    }

    /**
     * Update order status
     */
    @PutMapping("/{orderId}/status")
    public ResponseEntity<Order> updateOrderStatus(
            @PathVariable String orderId,
            @Valid @RequestBody UpdateOrderStatusRequest request) {
        
        log.info("Updating order {} status to: {}", orderId, request.getStatus());
        
        try {
            Order updatedOrder = orderBusinessService.updateOrderStatus(orderId, request.getStatus());
            return ResponseEntity.ok(updatedOrder);
        } catch (RuntimeException e) {
            log.error("Error updating order status: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
}
