# Postman Collection for Spring Boot gRPC Microservices

## 📦 Collection Overview

This folder contains a comprehensive Postman collection for testing the Order and Payment microservices.

### File
- **Spring-Boot-gRPC-Complete-Collection.json** - Complete test suite with 20+ requests and automated tests

## 🚀 Quick Start

### Option 1: Import JSON File (Recommended)

1. Open Postman Desktop or Postman Web
2. Click **Import** button (top left)
3. Select **Upload Files** tab
4. Choose `Spring-Boot-gRPC-Complete-Collection.json`
5. Click **Import**

### Option 2: Use Existing Collection

A collection has already been created in your Postman workspace:
- **Name**: Spring Boot gRPC - Order & Payment Services
- **ID**: 30673319-c55d3f8f-d83b-4b7b-8fa8-3806c1af10b1

## 📋 Collection Structure

The collection is organized into 4 main folders:

### 1. Health Checks (3 requests)
- ✅ Order Service Health
- ✅ Payment Service Health
- ✅ API Gateway Health

**Purpose**: Verify all services are running before running other tests

### 2. Order Service - CRUD Operations (6 requests)
- Create Order
- Get All Orders
- Get Order by ID
- Get Orders by User ID
- Get Orders by Status
- Update Order Status

**Purpose**: Test complete order lifecycle management

### 3. Payment Service - Query Operations (6 requests)
- Get All Payments
- Get Payment by ID
- Get Payment by Order ID
- Get Payments by User ID
- Get Payments by Status
- Get Payment Statistics

**Purpose**: Query and verify payments created by Kafka consumer

### 4. Integration Tests (3 requests)
- Step 1: Create Integration Test Order
- Step 2: Verify Payment Created (wait 5s)
- Step 3: Verify Order Database Persistence

**Purpose**: End-to-end testing of Order → Kafka → Payment flow

## 🎯 Running the Collection

### Running Individual Requests

1. Select any request from the collection
2. Click **Send** button
3. View the response and test results in the **Test Results** tab

### Running the Entire Collection

1. Click the **...** menu next to the collection name
2. Select **Run collection**
3. Configure run settings:
   - **Iterations**: 1 (default)
   - **Delay**: 3000ms (recommended for Kafka processing)
   - **Save responses**: Enable for debugging
4. Click **Run Spring Boot gRPC - Order & Payment Services**
5. View test results and assertions

## 📊 Test Assertions

Each request includes automated tests that verify:

### Health Checks
- ✓ Status code is 200
- ✓ Response time < 500ms
- ✓ Service status is "UP"
- ✓ Database connection is "UP"
- ✓ Kafka connection is "UP"

### Order Creation
- ✓ Status code is 201 Created
- ✓ Order ID is generated (UUID)
- ✓ User ID exists
- ✓ Order status is "PENDING"
- ✓ Total amount calculated correctly (quantity × price)
- ✓ Timestamps (createdAt, updatedAt) exist

### Order Retrieval
- ✓ Status code is 200
- ✓ Response is array (for list endpoints)
- ✓ All required fields present
- ✓ Order ID matches request
- ✓ Data integrity maintained

### Payment Verification
- ✓ Payment created automatically via Kafka
- ✓ Payment order ID matches original order
- ✓ Payment amount equals order total amount
- ✓ Payment status is "COMPLETED"
- ✓ Payment user ID matches order user ID

### Integration Tests
- ✓ Order → Kafka → Payment flow working correctly
- ✓ Payment created within 5 seconds
- ✓ Data consistency across services
- ✓ Database persistence verified

## 🔧 Environment Variables

The collection uses environment variables for flexibility. You can create a Postman environment with these variables:

### Required Variables
```json
{
  "baseUrlOrder": "http://localhost:8081",
  "baseUrlPayment": "http://localhost:8082",
  "baseUrlGateway": "http://localhost:8080"
}
```

### Auto-generated Variables (set by tests)
- `lastOrderId` - ID of the last created order
- `lastUserId` - ID of the last user
- `lastPaymentId` - ID of the last payment
- `integrationOrderId` - Order ID for integration tests
- `integrationUserId` - User ID for integration tests
- `expectedPaymentAmount` - Expected payment amount

### Creating an Environment

1. Click **Environments** in left sidebar
2. Click **+** to create new environment
3. Name it "Local Development"
4. Add the required variables
5. Click **Save**
6. Select the environment from the dropdown (top right)

## 📝 Usage Tips

### 1. Run Health Checks First
Always run the health checks folder first to ensure all services are running:
```
1. Health Checks → Order Service Health
2. Health Checks → Payment Service Health
3. Health Checks → API Gateway Health
```

### 2. Create Order Before Testing Payments
Payments are created automatically by the Kafka consumer when orders are created:
```
1. Order Service → Create Order
2. Wait 3-5 seconds
3. Payment Service → Get Payment by Order ID
```

### 3. Integration Test Flow
Run the integration tests in order:
```
1. Step 1 - Create Integration Test Order
2. Wait 5 seconds (pre-request script handles this)
3. Step 2 - Verify Payment Created
4. Step 3 - Verify Order Database Persistence
```

### 4. Using Random Data
The "Create Order" request uses Postman dynamic variables:
- `{{$randomInt}}` - Random integer
- `{{$randomProduct}}` - Random product name
- `{{$randomPrice}}` - Random price

You can customize the request body as needed.

## 🐛 Troubleshooting

### Issue: All requests fail with "Could not get response"

**Solution:**
1. Verify services are running: `docker-compose ps`
2. Check all services are healthy
3. Test health endpoints manually: `curl http://localhost:8081/api/health`

### Issue: Payment not found after creating order

**Solution:**
1. Wait 3-5 seconds for Kafka to process the event
2. Check Kafka logs: `docker logs kafka --tail 50`
3. Check Payment Service logs: `docker logs payment-service --tail 50`

### Issue: Tests failing with "expected PENDING but got CONFIRMED"

**Solution:**
1. Run requests individually instead of collection runner
2. Clear environment variables and start fresh
3. Check order status before updating

### Issue: Random data causing validation errors

**Solution:**
1. Use fixed values instead of `{{$randomInt}}`
2. Ensure quantity and price are valid numbers
3. Check Service logs for detailed error messages

## 📈 Expected Results

### Successful Collection Run

When you run the entire collection, you should see:

```
✅ Health Checks (3/3 passed)
✅ Order Service - CRUD Operations (6/6 passed)
✅ Payment Service - Query Operations (6/6 passed)
✅ Integration Tests (3/3 passed)

Total: 18/18 requests passed
Total Assertions: 80+ passed
Duration: ~30-45 seconds
```

### Sample Test Output

```
PASS ✓ Status code is 200
PASS ✓ Response time is less than 500ms
PASS ✓ Service status is UP
PASS ✓ Database status is UP
PASS ✓ Kafka status is UP
```

## 🔗 Related Documentation

- [../TESTING.md](../TESTING.md) - Complete testing guide with cURL examples
- [../Architecture.md](../Architecture.md) - System architecture and design
- [../README.md](../README.md) - Project overview and setup

## 📞 Support

If you encounter issues:

1. Check service logs: `docker-compose logs [service-name]`
2. Verify service health: `http://localhost:8081/api/health`
3. Review Kafka messages: `docker logs kafka`
4. Check database connection: `docker exec -it postgres-db psql -U myuser`

## 🎉 Success Criteria

Your Postman tests are working correctly when:

- ✅ All health checks pass (200 OK)
- ✅ Orders can be created (201 Created)
- ✅ Orders can be retrieved by ID, user, status  
- ✅ Order status can be updated
- ✅ Payments are automatically created for orders (via Kafka)
- ✅ Payment amount matches order total
- ✅ All integration tests pass
- ✅ Total assertions passed: 80+

**Happy Testing! 🚀**
