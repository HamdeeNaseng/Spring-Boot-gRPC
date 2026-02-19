import { test as base, expect, APIRequestContext } from '@playwright/test';
import { generateTestId, generateUserId, generateProductId, TestCleanup } from '../utils/test-helpers';
import { 
  Order, 
  CreateOrderRequest, 
  Payment, 
  PaymentStats,
  PageableResponse 
} from '../utils/types';

/**
 * Extended test fixtures with API clients
 */
type OrderServiceFixtures = {
  orderService: OrderServiceClient;
  testCleanup: TestCleanup;
};

export const test = base.extend<OrderServiceFixtures>({
  orderService: async ({ request }, use) => {
    const client = new OrderServiceClient(request);
    await use(client);
  },
  
  testCleanup: async ({}, use) => {
    const cleanup = new TestCleanup();
    await use(cleanup);
    await cleanup.cleanup();
  }
});

export { expect };

/**
 * Order Service API Client
 */
export class OrderServiceClient {
  private baseURL = 'http://localhost:8081/api';
  
  constructor(private request: APIRequestContext) {}
  
  async createOrder(data: CreateOrderRequest): Promise<Order> {
    const response = await this.request.post(`${this.baseURL}/orders`, {
      data
    });
    
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getOrders(page: number = 0, size: number = 10): Promise<PageableResponse<Order>> {
    const response = await this.request.get(`${this.baseURL}/orders`, {
      params: { page, size }
    });
    
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getOrderById(id: string): Promise<Order> {
    const response = await this.request.get(`${this.baseURL}/orders/${id}`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getOrdersByUser(userId: string): Promise<Order[]> {
    const response = await this.request.get(`${this.baseURL}/orders/user/${userId}`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getOrdersByStatus(status: string): Promise<PageableResponse<Order>> {
    const response = await this.request.get(`${this.baseURL}/orders/status/${status}`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async updateOrderStatus(id: string, status: string): Promise<Order> {
    const response = await this.request.put(`${this.baseURL}/orders/${id}/status`, {
      data: { status }
    });
    
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async healthCheck(): Promise<{ status: string }> {
    const response = await this.request.get(`http://localhost:8081/api/health`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
}

/**
 * Payment Service API Client
 */
export class PaymentServiceClient {
  private baseURL = 'http://localhost:8082/api';
  
  constructor(private request: APIRequestContext) {}
  
  async getPayments(): Promise<Payment[]> {
    const response = await this.request.get(`${this.baseURL}/payments`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getPaymentByOrderId(orderId: string): Promise<Payment> {
    const response = await this.request.get(`${this.baseURL}/payments/order/${orderId}`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getPaymentsByUser(userId: string): Promise<Payment[]> {
    const response = await this.request.get(`${this.baseURL}/payments/user/${userId}`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async getPaymentStats(): Promise<PaymentStats> {
    const response = await this.request.get(`${this.baseURL}/payments/stats`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
  
  async healthCheck(): Promise<{ status: string }> {
    const response = await this.request.get(`http://localhost:8082/api/health`);
    expect(response.ok()).toBeTruthy();
    return await response.json();
  }
}

/**
 * Test data factories
 */
export class TestDataFactory {
  static createOrderRequest(overrides?: Partial<CreateOrderRequest>): CreateOrderRequest {
    return {
      userId: generateUserId(),
      productId: generateProductId(),
      productName: 'Test Product',
      quantity: 1,
      price: 99.99,
      ...overrides
    };
  }
}
