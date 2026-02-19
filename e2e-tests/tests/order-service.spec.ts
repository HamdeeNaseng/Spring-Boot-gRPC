import { test, expect } from '../utils/fixtures';
import { OrderServiceClient, TestDataFactory } from '../utils/fixtures';
import { generateUserId, generateProductId } from '../utils/test-helpers';

/**
 * Order Service E2E Tests
 * 
 * Tests all Order Service REST API endpoints:
 * - POST /api/orders - Create order
 * - GET /api/orders - Get all orders (paginated)
 * - GET /api/orders/{id} - Get order by ID
 * - GET /api/orders/user/{userId} - Get orders by user
 * - GET /api/orders/status/{status} - Get orders by status
 * - PUT /api/orders/{id}/status - Update order status
 */

test.describe('Order Service API', () => {
  
  test.beforeAll(async ({ request }) => {
    // Health check before running tests
    const orderService = new OrderServiceClient(request);
    const health = await orderService.healthCheck();
    expect(health.status).toBe('UP');
  });
  
  test.describe('Health Check', () => {
    
    test('should return healthy status', async ({ orderService }) => {
      const health = await orderService.healthCheck();
      
      expect(health).toHaveProperty('status');
      expect(health.status).toBe('UP');
    });
    
  });
  
  test.describe('Create Order', () => {
    
    test('should create a new order successfully', async ({ orderService }) => {
      // Arrange
      const orderRequest = TestDataFactory.createOrderRequest({
        userId: 'test-user-001',
        productName: 'Laptop',
        quantity: 2,
        price: 999.99
      });
      
      // Act
      const order = await orderService.createOrder(orderRequest);
      
      // Assert
      expect(order).toBeDefined();
      expect(order.id).toBeDefined();
      expect(order.userId).toBe(orderRequest.userId);
      expect(order.productId).toBe(orderRequest.productId);
      expect(order.productName).toBe(orderRequest.productName);
      expect(order.quantity).toBe(orderRequest.quantity);
      expect(order.price).toBe(orderRequest.price);
      expect(order.totalPrice).toBe(orderRequest.quantity * orderRequest.price);
      expect(order.status).toBe('PENDING');
      expect(order.createdAt).toBeDefined();
      expect(order.updatedAt).toBeDefined();
    });
    
    test('should reject order with invalid quantity', async ({ request }) => {
      const orderRequest = TestDataFactory.createOrderRequest({
        quantity: 0  // Invalid: must be >= 1
      });
      
      const response = await request.post('http://localhost:8081/api/orders', {
        data: orderRequest
      });
      
      expect(response.status()).toBe(400);
    });
    
    test('should reject order with negative price', async ({ request }) => {
      const orderRequest = TestDataFactory.createOrderRequest({
        price: -10.00  // Invalid: must be > 0
      });
      
      const response = await request.post('http://localhost:8081/api/orders', {
        data: orderRequest
      });
      
      expect(response.status()).toBe(400);
    });
    
    test('should reject order with missing required fields', async ({ request }) => {
      const invalidRequest = {
        productName: 'Test Product',
        quantity: 1
        // Missing: userId, productId, price
      };
      
      const response = await request.post('http://localhost:8081/api/orders', {
        data: invalidRequest
      });
      
      expect(response.status()).toBe(400);
    });
    
  });
  
  test.describe('Get Orders', () => {
    
    test('should get all orders with pagination', async ({ orderService }) => {
      // Create some test orders first
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      
      // Get orders
      const response = await orderService.getOrders(0, 10);
      
      // Assert
      expect(response).toBeDefined();
      expect(response.content).toBeInstanceOf(Array);
      expect(response.totalElements).toBeGreaterThanOrEqual(2);
      expect(response.pageable.pageNumber).toBe(0);
      expect(response.pageable.pageSize).toBe(10);
      expect(response.first).toBe(true);
    });
    
    test('should support pagination parameters', async ({ orderService }) => {
      // Get page 0 with size 5
      const page1 = await orderService.getOrders(0, 5);
      expect(page1.size).toBe(5);
      expect(page1.number).toBe(0);
      
      // Get page 1 with size 5
      const page2 = await orderService.getOrders(1, 5);
      expect(page2.size).toBe(5);
      expect(page2.number).toBe(1);
    });
    
  });
  
  test.describe('Get Order by ID', () => {
    
    test('should get order by ID', async ({ orderService }) => {
      // Create an order
      const created = await orderService.createOrder(
        TestDataFactory.createOrderRequest({
          productName: 'Specific Product'
        })
      );
      
      // Get order by ID
      const fetched = await orderService.getOrderById(created.id);
      
      // Assert
      expect(fetched.id).toBe(created.id);
      expect(fetched.productName).toBe('Specific Product');
      expect(fetched.userId).toBe(created.userId);
      expect(fetched.totalPrice).toBe(created.totalPrice);
    });
    
    test('should return 404 for non-existent order', async ({ request }) => {
      const response = await request.get('http://localhost:8081/api/orders/non-existent-id');
      expect(response.status()).toBe(404);
    });
    
  });
  
  test.describe('Get Orders by User', () => {
    
    test('should get all orders for a specific user', async ({ orderService }) => {
      const userId = generateUserId();
      
      // Create multiple orders for the same user
      await orderService.createOrder(TestDataFactory.createOrderRequest({ userId }));
      await orderService.createOrder(TestDataFactory.createOrderRequest({ userId }));
      await orderService.createOrder(TestDataFactory.createOrderRequest({ userId }));
      
      // Get orders by user
      const userOrders = await orderService.getOrdersByUser(userId);
      
      // Assert
      expect(userOrders).toBeInstanceOf(Array);
      expect(userOrders.length).toBeGreaterThanOrEqual(3);
      userOrders.forEach(order => {
        expect(order.userId).toBe(userId);
      });
    });
    
    test('should return empty array for user with no orders', async ({ orderService }) => {
      const userId = `no-orders-${Date.now()}`;
      const userOrders = await orderService.getOrdersByUser(userId);
      
      expect(userOrders).toBeInstanceOf(Array);
      expect(userOrders.length).toBe(0);
    });
    
  });
  
  test.describe('Get Orders by Status', () => {
    
    test('should get orders by PENDING status', async ({ orderService }) => {
      // Create order (default status is PENDING)
      await orderService.createOrder(TestDataFactory.createOrderRequest());
      
      // Get pending orders
      const pendingOrders = await orderService.getOrdersByStatus('PENDING');
      
      // Assert
      expect(pendingOrders.content).toBeInstanceOf(Array);
      expect(pendingOrders.content.length).toBeGreaterThan(0);
      pendingOrders.content.forEach(order => {
        expect(order.status).toBe('PENDING');
      });
    });
    
    test('should get orders by COMPLETED status', async ({ orderService }) => {
      // Create and complete an order
      const order = await orderService.createOrder(TestDataFactory.createOrderRequest());
      await orderService.updateOrderStatus(order.id, 'COMPLETED');
      
      // Get completed orders
      const completedOrders = await orderService.getOrdersByStatus('COMPLETED');
      
      // Assert
      expect(completedOrders.content).toBeInstanceOf(Array);
      const completedOrder = completedOrders.content.find(o => o.id === order.id);
      expect(completedOrder).toBeDefined();
      expect(completedOrder?.status).toBe('COMPLETED');
    });
    
  });
  
  test.describe('Update Order Status', () => {
    
    test('should update order status from PENDING to PROCESSING', async ({ orderService }) => {
      // Create order
      const order = await orderService.createOrder(TestDataFactory.createOrderRequest());
      expect(order.status).toBe('PENDING');
      
      // Update status
      const updated = await orderService.updateOrderStatus(order.id, 'PROCESSING');
      
      // Assert
      expect(updated.id).toBe(order.id);
      expect(updated.status).toBe('PROCESSING');
      expect(updated.updatedAt).not.toBe(order.updatedAt);
    });
    
    test('should update order status to COMPLETED', async ({ orderService }) => {
      const order = await orderService.createOrder(TestDataFactory.createOrderRequest());
      const updated = await orderService.updateOrderStatus(order.id, 'COMPLETED');
      
      expect(updated.status).toBe('COMPLETED');
    });
    
    test('should update order status to CANCELLED', async ({ orderService }) => {
      const order = await orderService.createOrder(TestDataFactory.createOrderRequest());
      const updated = await orderService.updateOrderStatus(order.id, 'CANCELLED');
      
      expect(updated.status).toBe('CANCELLED');
    });
    
    test('should return 404 when updating non-existent order', async ({ request }) => {
      const response = await request.put('http://localhost:8081/api/orders/non-existent/status', {
        data: { status: 'COMPLETED' }
      });
      
      expect(response.status()).toBe(404);
    });
    
  });
  
  test.describe('Order Data Validation', () => {
    
    test('should calculate total price correctly', async ({ orderService }) => {
      const order = await orderService.createOrder(
        TestDataFactory.createOrderRequest({
          quantity: 5,
          price: 19.99
        })
      );
      
      const expectedTotal = 5 * 19.99;
      expect(order.totalPrice).toBe(expectedTotal);
    });
    
    test('should set timestamps correctly', async ({ orderService }) => {
      const beforeCreate = new Date();
      
      const order = await orderService.createOrder(TestDataFactory.createOrderRequest());
      
      const afterCreate = new Date();
      const createdAt = new Date(order.createdAt);
      
      expect(createdAt.getTime()).toBeGreaterThanOrEqual(beforeCreate.getTime());
      expect(createdAt.getTime()).toBeLessThanOrEqual(afterCreate.getTime());
    });
    
  });
  
});
