# End-to-End Tests for Spring Boot gRPC Microservices

Comprehensive Playwright test suite covering all REST API endpoints and integration flows.

## 📋 Table of Contents

- [Overview](#overview)
- [Test Coverage](#test-coverage)
- [Setup](#setup)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Test Reports](#test-reports)
- [CI/CD Integration](#cicd-integration)

## 🎯 Overview

This test suite provides comprehensive end-to-end testing for:

- **Order Service** (Port 8081) - Order management REST API
- **Payment Service** (Port 8082) - Payment processing REST API
- **Integration Flow** - Order → Kafka → Payment complete flow

## ✅ Test Coverage

### Order Service Tests (`order-service.spec.ts`)

**Health Check**
- ✅ Service health endpoint

**Create Order** (POST `/api/orders`)
- ✅ Create order successfully
- ✅ Validate required fields (userId, productId, productName, quantity, price)
- ✅ Reject invalid quantity (< 1)
- ✅ Reject negative price
- ✅ Reject missing required fields
- ✅ Calculate total price correctly
- ✅ Set timestamps correctly

**Get Orders** (GET `/api/orders`)
- ✅ Get all orders with pagination
- ✅ Support pagination parameters (page, size)
- ✅ Return correct pagination metadata

**Get Order by ID** (GET `/api/orders/{id}`)
- ✅ Get order by valid ID
- ✅ Return 404 for non-existent order

**Get Orders by User** (GET `/api/orders/user/{userId}`)
- ✅ Get all orders for specific user
- ✅ Return empty array for user with no orders

**Get Orders by Status** (GET `/api/orders/status/{status}`)
- ✅ Get orders by PENDING status
- ✅ Get orders by COMPLETED status
- ✅ Filter correctly by status

**Update Order Status** (PUT `/api/orders/{id}/status`)
- ✅ Update status: PENDING → PROCESSING
- ✅ Update status: PENDING → COMPLETED
- ✅ Update status: PENDING → CANCELLED
- ✅ Return 404 for non-existent order
- ✅ Update timestamp on status change

### Payment Service Tests (`payment-service.spec.ts`)

**Health Check**
- ✅ Service health endpoint

**Get All Payments** (GET `/api/payments`)
- ✅ Get all payments
- ✅ Return correct payment structure

**Get Payment Statistics** (GET `/api/payments/stats`)
- ✅ Get payment statistics
- ✅ Return valid numeric values
- ✅ Calculate totals correctly
- ✅ Calculate success rate correctly (0-100%)
- ✅ Non-negative values for all metrics

**Get Payments by User** (GET `/api/payments/user/{userId}`)
- ✅ Get payments for specific user
- ✅ Return empty array for user with no payments
- ✅ Filter payments by user correctly

**Get Payment by Order ID** (GET `/api/payments/order/{orderId}`)
- ✅ Get payment by valid order ID
- ✅ Return 404 for non-existent order
- ✅ Return correct error message

**Payment Validation**
- ✅ Valid payment statuses (PENDING, PROCESSING, COMPLETED, FAILED)
- ✅ Positive amounts

### Integration Tests (`e2e-flow.spec.ts`)

**Order to Payment Flow**
- ✅ Create order and trigger payment via Kafka
- ✅ Verify payment creation with retry logic
- ✅ Verify order-payment data consistency
- ✅ Handle multiple orders from same user
- ✅ Update order status after payment

**Payment Statistics**
- ✅ Reflect new payments in statistics
- ✅ Maintain consistent totals

**Error Handling**
- ✅ Handle non-existent orders gracefully
- ✅ Handle non-existent users gracefully

**Data Consistency**
- ✅ Maintain consistency across services
- ✅ Each order has corresponding payment
- ✅ Amounts match between order and payment

**Performance Tests**
- ✅ Order creation < 2 seconds
- ✅ Payment lookup < 1 second

## 🚀 Setup

### Prerequisites

- Node.js 18+ installed
- Docker services running (Order Service, Payment Service, Kafka)
- Services accessible at:
  - Order Service: http://localhost:8081
  - Payment Service: http://localhost:8082

### Installation

```bash
# Navigate to test directory
cd e2e-tests

# Install dependencies
npm install

# Install Playwright browsers
npx playwright install
```

## 🧪 Running Tests

### All Tests

```bash
npm test
```

### Specific Test Suites

```bash
# Order Service tests only
npm run test:order

# Payment Service tests only
npm run test:payment

# Integration/E2E tests only
npm run test:e2e
```

### Other Test Modes

```bash
# Run tests in headed mode (see browser)
npm run test:headed

# Run tests in debug mode
npm run test:debug

# Run tests with UI mode (interactive)
npm run test:ui

# View latest test report
npm run test:report
```

### Run Tests by Project

```bash
# Run only Order Service project tests
npx playwright test --project=order-service

# Run only Payment Service project tests
npx playwright test --project=payment-service

# Run only E2E integration tests
npx playwright test --project=e2e-integration
```

## 📁 Test Structure

```
e2e-tests/
├── playwright.config.ts        # Playwright configuration
├── tsconfig.json              # TypeScript configuration
├── package.json               # Dependencies and scripts
├── tests/
│   ├── order-service.spec.ts  # Order Service tests
│   ├── payment-service.spec.ts # Payment Service tests
│   └── e2e-flow.spec.ts       # Integration tests
├── utils/
│   ├── fixtures.ts            # Test fixtures and API clients
│   ├── types.ts               # TypeScript type definitions
│   └── test-helpers.ts        # Helper functions
└── test-results/              # Test outputs (auto-generated)
    ├── html-report/           # HTML test report
    └── results.json           # JSON test results
```

## 📊 Test Reports

After running tests, view reports:

```bash
# Open HTML report in browser
npm run test:report
```

Reports are generated in:
- `test-results/html-report/` - Interactive HTML report
- `test-results/results.json` - JSON format for CI/CD

## 🔧 Configuration

### Timeouts

Configured in [playwright.config.ts](playwright.config.ts):

- **Test timeout**: 30 seconds
- **Expect timeout**: 5 seconds

### Retries

- **CI environment**: 2 retries on failure
- **Local environment**: No retries

### Parallel Execution

- **CI environment**: Sequential (1 worker)
- **Local environment**: Parallel (multiple workers)

## 🐛 Debugging

### Debug a Specific Test

```bash
npx playwright test --debug tests/order-service.spec.ts
```

### View Test Traces

```bash
npx playwright show-trace test-results/trace.zip
```

### Console Output

Tests include detailed console logging:
- ✅ Success messages
- ⏳ Wait/retry indicators
- 📦 Order creation logs
- 💳 Payment verification logs
- 📊 Statistics updates

## 📝 Writing New Tests

### Example Test

```typescript
import { test, expect } from '../utils/fixtures';
import { OrderServiceClient, TestDataFactory } from '../utils/fixtures';

test('should create order', async ({ request }) => {
  const orderService = new OrderServiceClient(request);
  
  const order = await orderService.createOrder(
    TestDataFactory.createOrderRequest({
      productName: 'My Product',
      price: 99.99
    })
  );
  
  expect(order.id).toBeDefined();
  expect(order.status).toBe('PENDING');
});
```

### Using API Clients

**OrderServiceClient** provides:
- `createOrder(data)` - Create a new order
- `getOrders(page, size)` - Get paginated orders
- `getOrderById(id)` - Get order by ID
- `getOrdersByUser(userId)` - Get orders by user
- `getOrdersByStatus(status)` - Get orders by status
- `updateOrderStatus(id, status)` - Update order status
- `healthCheck()` - Check service health

**PaymentServiceClient** provides:
- `getPayments()` - Get all payments
- `getPaymentByOrderId(orderId)` - Get payment by order
- `getPaymentsByUser(userId)` - Get payments by user
- `getPaymentStats()` - Get payment statistics
- `healthCheck()` - Check service health

### Test Utilities

```typescript
import { 
  generateTestId, 
  generateUserId, 
  sleep, 
  waitFor, 
  retryWithBackoff 
} from '../utils/test-helpers';

// Generate unique IDs
const userId = generateUserId();
const testId = generateTestId();

// Wait for condition
await waitFor(
  async () => payment !== null,
  30000, // timeout
  2000   // check interval
);

// Retry with exponential backoff
const result = await retryWithBackoff(
  () => service.getData(),
  5,     // max retries
  1000   // initial delay
);
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Start services
        run: docker-compose up -d
      
      - name: Install dependencies
        working-directory: e2e-tests
        run: npm ci
      
      - name: Install Playwright
        working-directory: e2e-tests
        run: npx playwright install --with-deps
      
      - name: Run tests
        working-directory: e2e-tests
        run: npm test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: e2e-tests/test-results/
```

## 📈 Test Metrics

Current test suite provides:
- **Total Tests**: 50+ test cases
- **Order Service**: 20+ tests
- **Payment Service**: 15+ tests
- **Integration**: 15+ tests
- **Code Coverage**: REST API endpoints
- **Average Duration**: ~45 seconds (full suite)

## 🔍 Troubleshooting

### Services Not Running

```bash
# Check if services are up
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Start services
cd ..
docker-compose up -d
```

### Connection Refused

Ensure services are healthy:
```bash
docker-compose ps
docker-compose logs order-service
docker-compose logs payment-service
```

### Kafka Not Processing

Check Kafka logs:
```bash
docker-compose logs kafka
```

Wait a few seconds for Kafka to process events.

## 📚 Related Documentation

- [Testing Guide](../TESTING.md) - Manual testing guide
- [Postman Collection](../postman/README.md) - Postman API tests
- [Architecture](../Architecture.md) - System architecture
- [Deployment Summary](../DEPLOYMENT-SUMMARY.md) - Deployment guide

## 🤝 Contributing

When adding new tests:

1. Follow existing naming conventions
2. Add clear test descriptions
3. Include console logging for debugging
4. Update this README with new test cases
5. Ensure tests are idempotent (can run multiple times)

---

**Happy Testing! 🎉**
