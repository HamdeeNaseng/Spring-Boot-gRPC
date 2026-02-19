import { test, expect } from '@playwright/test';
import { PaymentServiceClient, OrderServiceClient, TestDataFactory } from '../utils/fixtures';
import { sleep } from '../utils/test-helpers';

/**
 * Payment Service E2E Tests
 * 
 * Tests all Payment Service REST API endpoints:
 * - GET /api/payments - Get all payments
 * - GET /api/payments/stats - Get payment statistics
 * - GET /api/payments/user/{userId} - Get payments by user
 * - GET /api/payments/order/{orderId} - Get payment by order ID
 * 
 * Note: Payment Service is a consumer that creates payments from Kafka events.
 * There is no direct POST endpoint for creating payments.
 */

test.describe('Payment Service API', () => {
  
  test.beforeAll(async ({ request }) => {
    // Health check before running tests
    const paymentService = new PaymentServiceClient(request);
    const health = await paymentService.healthCheck();
    expect(health.status).toBe('UP');
  });
  
  test.describe('Health Check', () => {
    
    test('should return healthy status', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const health = await paymentService.healthCheck();
      
      expect(health).toHaveProperty('status');
      expect(health.status).toBe('UP');
    });
    
  });
  
  test.describe('Get All Payments', () => {
    
    test('should get all payments', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const payments = await paymentService.getPayments();
      
      expect(payments).toBeInstanceOf(Array);
      // May be empty if no payments have been created yet
      expect(payments).toBeDefined();
    });
    
    test('should return payment array with correct structure', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const payments = await paymentService.getPayments();
      
      if (payments.length > 0) {
        const payment = payments[0];
        
        expect(payment).toHaveProperty('id');
        expect(payment).toHaveProperty('orderId');
        expect(payment).toHaveProperty('userId');
        expect(payment).toHaveProperty('amount');
        expect(payment).toHaveProperty('status');
        expect(payment).toHaveProperty('createdAt');
        expect(payment).toHaveProperty('updatedAt');
      }
    });
    
  });
  
  test.describe('Get Payment Statistics', () => {
    
    test('should get payment statistics', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const stats = await paymentService.getPaymentStats();
      
      expect(stats).toBeDefined();
      expect(stats).toHaveProperty('totalPayments');
      expect(stats).toHaveProperty('completed');
      expect(stats).toHaveProperty('failed');
      expect(stats).toHaveProperty('pending');
      expect(stats).toHaveProperty('processing');
      expect(stats).toHaveProperty('totalAmountProcessed');
      expect(stats).toHaveProperty('successRate');
    });
    
    test('should return valid numeric statistics', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const stats = await paymentService.getPaymentStats();
      
      expect(typeof stats.totalPayments).toBe('number');
      expect(typeof stats.completed).toBe('number');
      expect(typeof stats.failed).toBe('number');
      expect(typeof stats.pending).toBe('number');
      expect(typeof stats.processing).toBe('number');
      expect(typeof stats.totalAmountProcessed).toBe('number');
      expect(typeof stats.successRate).toBe('number');
      
      // Non-negative values
      expect(stats.totalPayments).toBeGreaterThanOrEqual(0);
      expect(stats.completed).toBeGreaterThanOrEqual(0);
      expect(stats.failed).toBeGreaterThanOrEqual(0);
      expect(stats.pending).toBeGreaterThanOrEqual(0);
      expect(stats.processing).toBeGreaterThanOrEqual(0);
      expect(stats.totalAmountProcessed).toBeGreaterThanOrEqual(0);
      
      // Success rate should be 0-100
      expect(stats.successRate).toBeGreaterThanOrEqual(0);
      expect(stats.successRate).toBeLessThanOrEqual(100);
    });
    
    test('should calculate totals correctly', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const stats = await paymentService.getPaymentStats();
      
      // Total should equal sum of all statuses
      const calculatedTotal = stats.completed + stats.failed + stats.pending + stats.processing;
      expect(stats.totalPayments).toBe(calculatedTotal);
    });
    
    test('should calculate success rate correctly', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const stats = await paymentService.getPaymentStats();
      
      if (stats.totalPayments > 0) {
        const expectedSuccessRate = (stats.completed / stats.totalPayments) * 100;
        expect(Math.abs(stats.successRate - expectedSuccessRate)).toBeLessThan(0.01);
      } else {
        expect(stats.successRate).toBe(0);
      }
    });
    
  });
  
  test.describe('Get Payments by User', () => {
    
    test('should get payments for a specific user', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      
      // Get all payments first
      const allPayments = await paymentService.getPayments();
      
      if (allPayments.length > 0) {
        const userId = allPayments[0].userId;
        
        // Get payments for this user
        const userPayments = await paymentService.getPaymentsByUser(userId);
        
        expect(userPayments).toBeInstanceOf(Array);
        expect(userPayments.length).toBeGreaterThan(0);
        
        // All payments should belong to the user
        userPayments.forEach(payment => {
          expect(payment.userId).toBe(userId);
        });
      }
    });
    
    test('should return empty array for user with no payments', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const userId = `no-payments-${Date.now()}`;
      
      const payments = await paymentService.getPaymentsByUser(userId);
      
      expect(payments).toBeInstanceOf(Array);
      expect(payments.length).toBe(0);
    });
    
  });
  
  test.describe('Get Payment by Order ID', () => {
    
    test('should get payment by order ID', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      
      // Get all payments first
      const allPayments = await paymentService.getPayments();
      
      if (allPayments.length > 0) {
        const orderId = allPayments[0].orderId;
        
        // Get payment by order ID
        const payment = await paymentService.getPaymentByOrderId(orderId);
        
        expect(payment).toBeDefined();
        expect(payment.orderId).toBe(orderId);
        expect(payment).toHaveProperty('id');
        expect(payment).toHaveProperty('userId');
        expect(payment).toHaveProperty('amount');
        expect(payment).toHaveProperty('status');
      }
    });
    
    test('should return 404 for non-existent order', async ({ request }) => {
      const response = await request.get('http://localhost:8082/api/payments/order/non-existent-order');
      expect(response.status()).toBe(404);
      
      const error = await response.json();
      expect(error).toHaveProperty('error');
      expect(error.error).toContain('not found');
    });
    
  });
  
  test.describe('Payment Status Validation', () => {
    
    test('should have valid payment statuses', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const payments = await paymentService.getPayments();
      
      const validStatuses = ['PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'];
      
      payments.forEach(payment => {
        expect(validStatuses).toContain(payment.status);
      });
    });
    
    test('should have positive amounts', async ({ request }) => {
      const paymentService = new PaymentServiceClient(request);
      const payments = await paymentService.getPayments();
      
      payments.forEach(payment => {
        expect(payment.amount).toBeGreaterThan(0);
      });
    });
    
  });
  
});
