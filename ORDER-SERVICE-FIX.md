# 🔧 Order Service REST API - Missing Endpoints Fixed

## ❌ Problem Identified

You received a 404 error when testing `/api/orders`:
```json
{
    "timestamp": "2026-02-19T10:48:25.431+00:00",
    "status": 404,
    "error": "Not Found",
    "path": "/api/orders"
}
```

**Root Cause**: Order Service only had a gRPC implementation but **NO REST endpoints** for CRUD operations.

## ✅ Solution Implemented

Created the missing REST API layer:

### 1. Created DTOs

#### CreateOrderRequest.java
- Path: `order-service/src/main/java/com/spring/grpc/order/dto/CreateOrderRequest.java`
- Fields: userId, productId, productName, quantity, price
- Validation: All fields required, quantity >= 1, price > 0

#### UpdateOrderStatusRequest.java
- Path: `order-service/src/main/java/com/spring/grpc/order/dto/UpdateOrderStatusRequest.java`
- Fields: status
- Validation: Status required

### 2. Created OrderController

**File**: `order-service/src/main/java/com/spring/grpc/order/controller/OrderController.java`

**Endpoints Created**:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/orders` | Create new order |
| GET | `/api/orders` | Get all orders (with pagination) |
| GET | `/api/orders/{orderId}` | Get order by ID |
| GET | `/api/orders/user/{userId}` | Get orders by user ID |
| GET | `/api/orders/status/{status}` | Get orders by status |
| PUT | `/api/orders/{orderId}/status` | Update order status |

**Features**:
- ✅ Full CRUD operations
- ✅ Pagination support (page, size parameters)
- ✅ Input validation
- ✅ Error handling (404 for not found)
- ✅ CORS enabled for Postman testing
- ✅ Kafka event publishing (order created, order updated)

## 🚀 Rebuild Instructions

### Option 1: Using PowerShell Script (Recommended)

```powershell
# Navigate to project root
cd D:\imed-\GitHub\Spring-Boot-gRPC

# Run rebuild script
.\rebuild-order-service.ps1
```

This script will:
1. Build with Maven (`mvn clean package -DskipTests`)
2. Rebuild Docker image (`docker-compose build order-service`)
3. Restart container (`docker-compose up -d order-service`)
4. Test health endpoint

### Option 2: Manual Steps

```powershell
# 1. Build with Maven
cd D:\imed-\GitHub\Spring-Boot-gRPC\order-service
mvn clean package -DskipTests

# 2. Navigate back to root
cd ..

# 3. Rebuild and restart service
docker-compose build order-service
docker-compose up -d order-service

# 4. Wait for service to start
Start-Sleep -Seconds 30

# 5. Test health endpoint
Invoke-RestMethod -Uri "http://localhost:8081/api/health"
```

### Option 3: Quick Docker-only Rebuild

```powershell
cd D:\imed-\GitHub\Spring-Boot-gRPC

# This will compile inside Docker and restart
docker-compose up -d --build order-service

# Wait for startup
Start-Sleep -Seconds 30
```

## 🧪 Testing the REST API

### 1. Health Check
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/health"
```

Expected response:
```json
{
  "status": "UP",
  "service": "order-service",
  "database": "UP",
  "kafka": "UP"
}
```

### 2. Create Order
```powershell
$body = @{
    userId = "user-001"
    productId = "prod-12345"
    productName = "Laptop"
    quantity = 2
    price = 999.99
} | ConvertTo-Json

$order = Invoke-RestMethod -Uri "http://localhost:8081/api/orders" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

# Save the order ID
$orderId = $order.orderId
Write-Host "Order ID: $orderId"
```

Expected response (201 Created):
```json
{
  "orderId": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "user-001",
  "productId": "prod-12345",
  "productName": "Laptop",
  "quantity": 2,
  "price": 999.99,
  "totalAmount": 1999.98,
  "status": "PENDING",
  "createdAt": "2026-02-19T10:50:00",
  "updatedAt": "2026-02-19T10:50:00"
}
```

### 3. Get All Orders
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/orders?page=0&size=10"
```

### 4. Get Order by ID
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/orders/$orderId"
```

### 5. Get Orders by User
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/orders/user/user-001?page=0&size=10"
```

### 6. Get Orders by Status
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/orders/status/PENDING?page=0&size=10"
```

Valid statuses: `PENDING`, `CONFIRMED`, `SHIPPED`, `DELIVERED`, `CANCELLED`

### 7. Update Order Status
```powershell
$statusUpdate = @{ status = "CONFIRMED" } | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/api/orders/$orderId/status" `
    -Method PUT `
    -Body $statusUpdate `
    -ContentType "application/json"
```

### 8. Verify Payment Created (via Kafka)
```powershell
# Wait 5 seconds for Kafka processing
Start-Sleep -Seconds 5

# Check payment was created
Invoke-RestMethod -Uri "http://localhost:8082/api/payments/order/$orderId"
```

Expected response:
```json
{
  "paymentId": "payment-uuid",
  "orderId": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "user-001",
  "amount": 1999.98,
  "status": "COMPLETED",
  "paymentMethod": "CREDIT_CARD",
  "createdAt": "2026-02-19T10:50:05"
}
```

## 📋 Complete Test Script

Use the automated test script:
```powershell
.\test-order-service.ps1
```

This script will:
1. Rebuild the Order Service
2. Wait for startup (30 seconds)
3. Test health endpoint
4. Create a test order
5. Retrieve the created order
6. Get all orders
7. Verify payment was created via Kafka
8. Display all results

## 🔄 Integration with Postman

Once the service is rebuilt, your Postman collection will work:

1. **Import Collection**: `postman/Spring-Boot-gRPC-Complete-Collection.json`
2. **Run Health Checks** folder first
3. **Run Order Service API** folder to test all endpoints
4. **Run Integration Tests** to verify Order → Kafka → Payment flow

## 📊 Expected Results After Rebuild

### Service Status
```powershell
docker-compose ps order-service
```

Should show: `Up, healthy`

### Available Endpoints
- ✅ `GET /api/health` - Health check
- ✅ `POST /api/orders` - Create order
- ✅ `GET /api/orders` - List orders
- ✅ `GET /api/orders/{id}` - Get order
- ✅ `GET /api/orders/user/{userId}` - User's orders
- ✅ `GET /api/orders/status/{status}` - Orders by status
- ✅ `PUT /api/orders/{id}/status` - Update status

### Service Logs
```powershell
docker logs order-service --tail 50
```

Should show:
```
Started OrderServiceApplication
Tomcat started on port(s): 8081 (http)
gRPC Server started, listening on port 9091
Mapped "{[/api/orders],methods=[POST]}" onto OrderController.createOrder()
Mapped "{[/api/orders],methods=[GET]}" onto OrderController.getAllOrders()
...
```

## 🐛 Troubleshooting

### Build Fails
```powershell
# Check Maven version
mvn --version

# Clean build
cd order-service
mvn clean install -DskipTests -X  # -X for debug output
```

### Container Won't Start
```powershell
# Check logs
docker logs order-service --tail 100

# Check if port 8081 is in use
netstat -ano | findstr :8081

# Force rebuild
docker-compose down
docker-compose up -d --build order-service
```

### Still Getting 404
```powershell
# Verify service is running
docker-compose ps | findstr order-service

# Check if controller is loaded
docker logs order-service | findstr "Mapped"

# Test locally inside container
docker exec order-service curl -s http://localhost:8081/api/health
```

### Payment Not Created
```powershell
# Check Kafka logs
docker logs kafka --tail 50

# Check Payment Service logs
docker logs payment-service --tail 50

# Verify Kafka topic exists
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

## 📝 Files Created

1. `order-service/src/main/java/com/spring/grpc/order/dto/CreateOrderRequest.java`
2. `order-service/src/main/java/com/spring/grpc/order/dto/UpdateOrderStatusRequest.java`
3. `order-service/src/main/java/com/spring/grpc/order/controller/OrderController.java`
4. `rebuild-order-service.ps1`
5. `test-order-service.ps1`
6. `ORDER-SERVICE-FIX.md` (this file)

## ✅ Next Steps

1. Run `.\rebuild-order-service.ps1` to rebuild the service
2. Wait 30 seconds for startup
3. Test with `.\test-order-service.ps1`
4. Use Postman collection for comprehensive testing
5. Verify Order → Kafka → Payment flow works

## 🎉 Summary

**Problem**: Order Service had no REST endpoints (only gRPC)  
**Solution**: Created full REST API with 6 endpoints  
**Status**: Ready to rebuild and test  
**Impact**: Postman collection will now work without 404 errors

---

**Need help?** Check service logs: `docker logs order-service --tail 100`
