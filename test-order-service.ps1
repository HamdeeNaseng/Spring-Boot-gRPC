# Rebuild Order Service with new REST endpoints
Write-Host "=== Rebuilding Order Service ===" -ForegroundColor Cyan

# Navigate to project root
Set-Location "D:\imed-\GitHub\Spring-Boot-gRPC"

# Rebuild and restart Order Service
Write-Host "`nRebuilding Order Service container..." -ForegroundColor Yellow
docker-compose up -d --build order-service

# Wait for service to start
Write-Host "`nWaiting for service to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host "`n=== Service Status ===" -ForegroundColor Cyan
docker-compose ps order-service

# Test health endpoint
Write-Host "`n=== Testing Health Endpoint ===" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8081/api/health" -Method GET
    Write-Host "Health Status: " -NoNewline
    Write-Host $health.status -ForegroundColor Green
} catch {
    Write-Host "Health check failed: $_" -ForegroundColor Red
}

# Test create order endpoint
Write-Host "`n=== Testing Create Order Endpoint ===" -ForegroundColor Cyan
$orderPayload = @{
    userId = "test-user-001"
    productId = "prod-12345"
    productName = "Test Product"
    quantity = 2
    price = 99.99
} | ConvertTo-Json

try {
    $order = Invoke-RestMethod -Uri "http://localhost:8081/api/orders" `
        -Method POST `
        -Body $orderPayload `
        -ContentType "application/json"
    
    Write-Host "Order created successfully!" -ForegroundColor Green
    Write-Host "Order ID: $($order.orderId)"
    Write-Host "Status: $($order.status)"
    Write-Host "Total Amount: $($order.totalAmount)"
    
    # Save order ID for next test
    $orderId = $order.orderId
    
    # Wait for Kafka processing
    Write-Host "`nWaiting for Kafka to process order (5 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Test get order by ID
    Write-Host "`n=== Testing Get Order by ID ===" -ForegroundColor Cyan
    $retrievedOrder = Invoke-RestMethod -Uri "http://localhost:8081/api/orders/$orderId" -Method GET
    Write-Host "Order retrieved successfully!" -ForegroundColor Green
    Write-Host "Order ID: $($retrievedOrder.orderId)"
    Write-Host "Status: $($retrievedOrder.status)"
    
    # Test get all orders
    Write-Host "`n=== Testing Get All Orders ===" -ForegroundColor Cyan
    $allOrders = Invoke-RestMethod -Uri "http://localhost:8081/api/orders?page=0&size=10" -Method GET
    Write-Host "Found $($allOrders.Count) orders" -ForegroundColor Green
    
    # Check payment was created
    Write-Host "`n=== Checking Payment Service ===" -ForegroundColor Cyan
    try {
        $payment = Invoke-RestMethod -Uri "http://localhost:8082/api/payments/order/$orderId" -Method GET
        Write-Host "Payment created via Kafka!" -ForegroundColor Green
        Write-Host "Payment ID: $($payment.paymentId)"
        Write-Host "Payment Amount: $($payment.amount)"
        Write-Host "Payment Status: $($payment.status)"
    } catch {
        Write-Host "Payment not found yet (Kafka may still be processing)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error testing Order Service: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
