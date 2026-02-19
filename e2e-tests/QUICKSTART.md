# Playwright E2E Tests - Quick Start

## 🚀 Quick Setup

```bash
# 1. Navigate to test directory
cd e2e-tests

# 2. Run setup script
.\setup.ps1

# 3. Ensure services are running
cd ..
docker-compose up -d

# 4. Run tests
cd e2e-tests
.\run-tests.ps1
```

## 📋 Test Suites

### Run All Tests
```bash
.\run-tests.ps1
```

### Run Specific Suite
```bash
# Order Service tests only
.\run-tests.ps1 -TestSuite order

# Payment Service tests only
.\run-tests.ps1 -TestSuite payment

# E2E Integration tests only
.\run-tests.ps1 -TestSuite e2e
```

### Run with UI
```bash
# Interactive UI mode
.\run-tests.ps1 -UI

# Headed mode (see browser)
.\run-tests.ps1 -Headed

# Debug mode
.\run-tests.ps1 -Debug
```

## 📊 Test Coverage

✅ **50+ Test Cases**

### Order Service (20+ tests)
- Create order with validation
- Get all orders (paginated)
- Get order by ID
- Get orders by user
- Get orders by status
- Update order status
- Error handling

### Payment Service (15+ tests)
- Get all payments
- Get payment statistics
- Get payments by user
- Get payment by order ID
- Validation tests

### E2E Integration (15+ tests)
- Order → Kafka → Payment flow
- Data consistency
- Performance tests
- Error handling

## 🔍 View Results

```bash
# View HTML report
npm run test:report
```

## 📚 Full Documentation

See [README.md](README.md) for complete documentation.

---

**Test Files:**
- `tests/order-service.spec.ts` - Order Service tests
- `tests/payment-service.spec.ts` - Payment Service tests
- `tests/e2e-flow.spec.ts` - Integration tests
