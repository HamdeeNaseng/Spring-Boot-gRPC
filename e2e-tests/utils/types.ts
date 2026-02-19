/**
 * Type definitions for Order Service
 */

export interface CreateOrderRequest {
  userId: string;
  productId: string;
  productName: string;
  quantity: number;
  price: number;
}

export interface UpdateOrderStatusRequest {
  status: string;
}

export interface Order {
  id: string;
  userId: string;
  productId: string;
  productName: string;
  quantity: number;
  price: number;
  totalPrice: number;
  status: string;
  createdAt: string;
  updatedAt: string;
}

export interface PageableResponse<T> {
  content: T[];
  pageable: {
    pageNumber: number;
    pageSize: number;
    sort: {
      sorted: boolean;
      unsorted: boolean;
      empty: boolean;
    };
    offset: number;
    paged: boolean;
    unpaged: boolean;
  };
  totalPages: number;
  totalElements: number;
  last: boolean;
  size: number;
  number: number;
  sort: {
    sorted: boolean;
    unsorted: boolean;
    empty: boolean;
  };
  numberOfElements: number;
  first: boolean;
  empty: boolean;
}

/**
 * Type definitions for Payment Service
 */

export interface Payment {
  id: string;
  orderId: string;
  userId: string;
  amount: number;
  status: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaymentStats {
  totalPayments: number;
  completed: number;
  failed: number;
  pending: number;
  processing: number;
  totalAmountProcessed: number;
  successRate: number;
}

/**
 * Common error response
 */

export interface ErrorResponse {
  error: string;
  message?: string;
  timestamp?: string;
  path?: string;
}
