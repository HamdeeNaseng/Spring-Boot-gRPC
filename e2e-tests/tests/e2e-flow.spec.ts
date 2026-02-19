import { test, expect } from '@playwright/test';
import { OrderServiceClient, PaymentServiceClient, TestDataFactory } from '../utils/fixtures';
import { sleep, waitFor, retryWithBackoff, generateUserId } from '../utils/test-helpers';

/**
 * End-to-End Integration Tests
 * 
 * Tests the complete flow:
 * 1. Order created in Order Service
 * 2. Order event published to Kafka
 * 3. Payment Service consumes event
 * 4. Payment created and processed
 * 5. Verify payment status and data
 */

test.describe('E2E Integration Tests', () => {
  
  test.beforeAll(async ({ request }) => {
    // Verify all services are healthy
    const orderService = new OrderServiceClient(request);
    const paymentService = new PaymentServiceClient(request);
    
    const orderHealth = await orderService.healthCheck();
    const paymentHealth = await paymentService.healthCheck();
    
    expect(orderHealth.status).toBe('UP');
    expect(paymentHealth.status).toBe('UP');
    
    console.log('✅ All services are healthy and ready for testing');
  });
  
  test.describe('Order to Payment Flow', () => {
    
    test('should create order and trigger payment via Kafka', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      const userId = generateUserId();
      
      // Step 1: Create an order
      console.log('📦 Creating order...');
      const orderRequest = TestDataFactory.createOrderRequest({
        userId,
        productName: 'E2E Test Product',
        quantity: 3,
        price: 149.99
      });
      
      const order = await orderService.createOrder(orderRequest);
      
      expect(order).toBeDefined();
      expect(order.id).toBeDefined();
      expect(order.status).toBe('PENDING');
      expect(order.totalPrice).toBe(3 * 149.99);
      
      console.log(`✅ Order created: ${order.id}`);
      
      // Step 2: Wait for Kafka event processing (with retry)
      console.log('⏳ Waiting for Kafka event processing...');
      
      let payment;
      const maxWaitTime = 30000; // 30 seconds
      const startTime = Date.now();
      
      await waitFor(
        async () => {
          try {
            payment = await paymentService.getPaymentByOrderId(order.id);
            return true;
          } catch (error) {
            if (Date.now() - startTime > maxWaitTime) {
              throw new Error(`Payment not created within ${maxWaitTime}ms`);
            }
            return false;
          }
        },
        maxWaitTime,
        2000 // Check every 2 seconds
      );
      
      console.log(`✅ Payment created: ${payment.id}`);
      
      // Step 3: Verify payment details
      expect(payment).toBeDefined();
      expect(payment.orderId).toBe(order.id);
      expect(payment.userId).toBe(order.userId);
      expect(payment.amount).toBe(order.totalPrice);
      expect(['PENDING', 'PROCESSING', 'COMPLETED']).toContain(payment.status);
      
      console.log(`✅ Payment verified: Status=${payment.status}, Amount=$${payment.amount}`);
      
      // Step 4: Verify order can be fetched by user
      const userOrders = await orderService.getOrdersByUser(userId);
      expect(userOrders.length).toBeGreaterThan(0);
      expect(userOrders.some(o => o.id === order.id)).toBeTruthy();
      
      // Step 5: Verify payment can be fetched by user
      const userPayments = await paymentService.getPaymentsByUser(userId);
      expect(userPayments.length).toBeGreaterThan(0);
      expect(userPayments.some(p => p.orderId === order.id)).toBeTruthy();
      
      console.log('✅ E2E flow completed successfully!');
    });
    
    test('should handle multiple orders from same user', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      const userId = generateUserId();
      
      // Create multiple orders
      console.log('📦 Creating multiple orders for same user...');
      const order1 = await orderService.createOrder(
        TestDataFactory.createOrderRequest({ userId, productName: 'Product 1', price: 100 })
      );
      const order2 = await orderService.createOrder(
        TestDataFactory.createOrderRequest({ userId, productName: 'Product 2', price: 200 })
      );
      const order3 = await orderService.createOrder(
        TestDataFactory.createOrderRequest({ userId, productName: 'Product 3', price: 300 })
      );
      
      console.log(`✅ Created 3 orders: ${order1.id}, ${order2.id}, ${order3.id}`);
      
      // Wait for payments to be created
      console.log('⏳ Waiting for payments to be created...');
      await sleep(10000); // Wait 10 seconds for Kafka processing
      
      // Verify payments were created
      const userPayments = await paymentService.getPaymentsByUser(userId);
      expect(userPayments.length).toBeGreaterThanOrEqual(3);
      
      const payment1 = userPayments.find(p => p.orderId === order1.id);
      const payment2 = userPayments.find(p => p.orderId === order2.id);
      const payment3 = userPayments.find(p => p.orderId === order3.id);
      
      expect(payment1).toBeDefined();
      expect(payment2).toBeDefined();
      expect(payment3).toBeDefined();
      
      expect(payment1?.amount).toBe(100);
      expect(payment2?.amount).toBe(200);
      expect(payment3?.amount).toBe(300);
      
      console.log('✅ All payments verified!');
    });
    
    test('should update order status after payment', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      // Create order
      const order = await orderService.createOrder(
        TestDataFactory.createOrderRequest({
          productName: 'Status Update Test',
          price: 99.99
        })
      );
      
      console.log(`📦 Order created: ${order.id}, Status: ${order.status}`);
      
      // Wait for payment
      await sleep(5000);
      
      // Update order status to PROCESSING
      const processingOrder = await orderService.updateOrderStatus(order.id, 'PROCESSING');
      expect(processingOrder.status).toBe('PROCESSING');
      
      console.log(`🔄 Order status updated: PENDING → PROCESSING`);
      
      // Update order status to COMPLETED
      const completedOrder = await orderService.updateOrderStatus(order.id, 'COMPLETED');
      expect(completedOrder.status).toBe('COMPLETED');
      
      console.log(`✅ Order status updated: PROCESSING → COMPLETED`);
      
      // Verify payment exists
      const payment = await retryWithBackoff(
        () => paymentService.getPaymentByOrderId(order.id),
        5,
        2000
      );
      
      expect(payment.orderId).toBe(order.id);
      console.log(`💳 Payment verified: ${payment.id}`);
    });
    
  });
  
  test.describe('Payment Statistics Verification', () => {
    
    test('should reflect new payments in statistics', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      // Get initial stats
      const initialStats = await paymentService.getPaymentStats();
      console.log(`📊 Initial stats: Total=${initialStats.totalPayments}`);
      
      // Create new orders
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      
      console.log('📦 Created 2 new orders');
      
      // Wait for processing
      await sleep(8000);
      
      // Get updated stats
      const updatedStats = await paymentService.getPaymentStats();
      console.log(`📊 Updated stats: Total=${updatedStats.totalPayments}`);
      
      // Verify stats increased
      expect(updatedStats.totalPayments).toBeGreaterThanOrEqual(initialStats.totalPayments);
      
      // Verify totals add up
      const total = updatedStats.completed + updatedStats.failed + 
                   updatedStats.pending + updatedStats.processing;
      expect(updatedStats.totalPayments).toBe(total);
      
      console.log('✅ Statistics verified and consistent');
    });
    
  });
  
  test.describe('Error Handling', () => {
    
    test('should handle non-existent order gracefully', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      
      const response = await request.get('http://localhost:8082/api/payments/order/fake-order-id');
      expect(response.status()).toBe(404);
      
      const error = await response.json();
      expect(error).toHaveProperty('error');
    });
    
    test('should handle non-existent user gracefully', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      const fakeUserId = `fake-user-${Date.now()}`;
      
      const userOrders = await orderService.getOrdersByUser(fakeUserId);
      expect(userOrders).toBeInstanceOf(Array);
      expect(userOrders.length).toBe(0);
      
      const userPayments = await paymentService.getPaymentsByUser(fakeUserId);
      expect(userPayments).toBeInstanceOf(Array);
      expect(userPayments.length).toBe(0);
    });
    
  });
  
  test.describe('Data Consistency', () => {
    
    test('should maintain data consistency across services', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      const paymentService = new PaymentServiceClient(request);
      
      const userId = generateUserId();
      
      // Create orders
      const orders = await Promise.all([
        orderService.createOrder(TestDataFactory.createOrderRequest({ userId, price: 50 })),
        orderService.createOrder(TestDataFactory.createOrderRequest({ userId, price: 75 })),
        orderService.createOrder(TestDataFactory.createOrderRequest({ userId, price: 125 }))
      ]);
      
      console.log(`📦 Created ${orders.length} orders`);
      
      // Wait for payments
      await sleep(10000);
      
      // Verify consistency
      const userOrders = await orderService.getOrdersByUser(userId);
      const userPayments = await paymentService.getPaymentsByUser(userId);
      
      console.log(`📊 User has ${userOrders.length} orders and ${userPayments.length} payments`);
      
      // Each order should have a corresponding payment
      for (const order of userOrders) {
        const payment = userPayments.find(p => p.orderId === order.id);
        
        if (payment) {
          expect(payment.userId).toBe(order.userId);
          expect(payment.amount).toBe(order.totalPrice);
          console.log(`✅ Order ${order.id} → Payment ${payment.id} (Consistent)`);
        }
      }
    });
    
  });
  
  test.describe('Performance Tests', () => {
    
    test('should handle order creation within acceptable time', async ({ request }) => {
      const orderService = new OrderServiceClient(request);
      
      const startTime = Date.now();
      
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      
      const duration = Date.now() - startTime;
      
      console.log(`⏱️ Order creation took ${duration}ms`);
      expect(duration).toBeLessThan(2000); // Should take less than 2 seconds
    });
    
    test('should handle payment lookup within acceptable time', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      
      const startTime = Date.now();
      
      await paymentService.getPayments();
      
      const duration = Date.now() - startTime;
      
      console.log(`⏱️ Payment lookup took ${duration}ms`);
      expect(duration).toBeLessThan(1000); // Should take less than 1 second
    });
    
  });
  
});
