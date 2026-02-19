package com.spring.grpc.order.service;

import com.spring.grpc.order.entity.Order;
import com.spring.grpc.proto.*;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.devh.boot.grpc.server.service.GrpcService;
import org.springframework.data.domain.Page;

import java.time.format.DateTimeFormatter;
import java.util.Optional;

/**
 * gRPC Service Implementation for Order Service
 */
@GrpcService
@RequiredArgsConstructor
@Slf4j
public class OrderServiceImpl extends OrderServiceGrpc.OrderServiceImplBase {

    private final OrderBusinessService orderBusinessService;
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @Override
    public void createOrder(CreateOrderRequest request, 
                           StreamObserver<CreateOrderResponse> responseObserver) {
        try {
            log.info("Received createOrder request for user: {}", request.getUserId());

            // Create order
            Order order = orderBusinessService.createOrder(
                    request.getUserId(),
                    request.getProductId(),
                    request.getProductName(),
                    request.getQuantity(),
                    request.getPrice()
            );

            // Build response
            CreateOrderResponse response = CreateOrderResponse.newBuilder()
                    .setOrderId(order.getOrderId())
                    .setUserId(order.getUserId())
                    .setProductId(order.getProductId())
                    .setProductName(order.getProductName())
                    .setQuantity(order.getQuantity())
                    .setPrice(order.getPrice())
                    .setTotalAmount(order.getTotalAmount())
                    .setStatus(order.getStatus())
                    .setCreatedAt(order.getCreatedAt().format(FORMATTER))
                    .setMessage("Order created successfully")
                    .build();

            responseObserver.onNext(response);
            responseObserver.onCompleted();

            log.info("Successfully created order: {}", order.getOrderId());

        } catch (Exception e) {
            log.error("Error creating order", e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription("Error creating order: " + e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void getOrder(GetOrderRequest request, 
                        StreamObserver<GetOrderResponse> responseObserver) {
        try {
            log.info("Received getOrder request for orderId: {}", request.getOrderId());

            Optional<Order> orderOpt = orderBusinessService.getOrderById(request.getOrderId());

            if (orderOpt.isEmpty()) {
                responseObserver.onError(io.grpc.Status.NOT_FOUND
                        .withDescription("Order not found: " + request.getOrderId())
                        .asRuntimeException());
                return;
            }

            Order order = orderOpt.get();
            GetOrderResponse response = buildGetOrderResponse(order);

            responseObserver.onNext(response);
            responseObserver.onCompleted();

            log.info("Successfully retrieved order: {}", order.getOrderId());

        } catch (Exception e) {
            log.error("Error retrieving order", e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription("Error retrieving order: " + e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void listOrders(ListOrdersRequest request, 
                          StreamObserver<ListOrdersResponse> responseObserver) {
        try {
            log.info("Received listOrders request - page: {}, size: {}", 
                    request.getPage(), request.getSize());

            int page = request.getPage() > 0 ? request.getPage() : 0;
            int size = request.getSize() > 0 ? request.getSize() : 10;
            String userId = request.getUserId().isEmpty() ? null : request.getUserId();

            Page<Order> ordersPage = orderBusinessService.listOrders(page, size, userId);

            ListOrdersResponse.Builder responseBuilder = ListOrdersResponse.newBuilder()
                    .setTotalCount((int) ordersPage.getTotalElements())
                    .setPage(ordersPage.getNumber())
                    .setSize(ordersPage.getSize());

            ordersPage.getContent().forEach(order -> 
                    responseBuilder.addOrders(buildGetOrderResponse(order)));

            responseObserver.onNext(responseBuilder.build());
            responseObserver.onCompleted();

            log.info("Successfully listed {} orders", ordersPage.getContent().size());

        } catch (Exception e) {
            log.error("Error listing orders", e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription("Error listing orders: " + e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void updateOrderStatus(UpdateOrderStatusRequest request, 
                                  StreamObserver<UpdateOrderStatusResponse> responseObserver) {
        try {
            log.info("Received updateOrderStatus request for orderId: {} -> {}", 
                    request.getOrderId(), request.getStatus());

            Order updatedOrder = orderBusinessService.updateOrderStatus(
                    request.getOrderId(),
                    request.getStatus()
            );

            UpdateOrderStatusResponse response = UpdateOrderStatusResponse.newBuilder()
                    .setOrderId(updatedOrder.getOrderId())
                    .setStatus(updatedOrder.getStatus())
                    .setUpdatedAt(updatedOrder.getUpdatedAt().format(FORMATTER))
                    .setMessage("Order status updated successfully")
                    .build();

            responseObserver.onNext(response);
            responseObserver.onCompleted();

            log.info("Successfully updated order status: {}", updatedOrder.getOrderId());

        } catch (Exception e) {
            log.error("Error updating order status", e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription("Error updating order status: " + e.getMessage())
                    .asRuntimeException());
        }
    }

    private GetOrderResponse buildGetOrderResponse(Order order) {
        return GetOrderResponse.newBuilder()
                .setOrderId(order.getOrderId())
                .setUserId(order.getUserId())
                .setProductId(order.getProductId())
                .setProductName(order.getProductName())
                .setQuantity(order.getQuantity())
                .setPrice(order.getPrice())
                .setTotalAmount(order.getTotalAmount())
                .setStatus(order.getStatus())
                .setCreatedAt(order.getCreatedAt().format(FORMATTER))
                .setUpdatedAt(order.getUpdatedAt().format(FORMATTER))
                .build();
    }
}
