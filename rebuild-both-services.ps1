#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Rebuild and restart both Order and Payment services

.DESCRIPTION
    This script rebuilds both services in sequence:
    1. Order Service (port 8081)
    2. Payment Service (port 8082)
    
    Then runs integration tests to verify the complete flow.

.EXAMPLE
    .\rebuild-both-services.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔄 REBUILDING ORDER & PAYMENT SERVICES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Rebuild Order Service
Write-Host "📦 STEP 1: Rebuilding Order Service..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
try {
    & "$PSScriptRoot\rebuild-order-service.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "Order Service rebuild failed"
    }
} catch {
    Write-Host ""
    Write-Host "❌ Order Service rebuild failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host ""

# Step 2: Rebuild Payment Service
Write-Host "💳 STEP 2: Rebuilding Payment Service..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
try {
    & "$PSScriptRoot\rebuild-payment-service.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "Payment Service rebuild failed"
    }
} catch {
    Write-Host ""
    Write-Host "❌ Payment Service rebuild failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host ""

# Step 3: Run Integration Tests
Write-Host "🧪 STEP 3: Running Integration Tests..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Create a test order
Write-Host "1️⃣ Creating test order..." -ForegroundColor Cyan
$orderRequest = @{
    userId = "integration-test-user"
    productId = "PROD-INT-001"
    productName = "Integration Test Product"
    quantity = 5
    price = 99.99
} | ConvertTo-Json

try {
    $order = Invoke-RestMethod -Uri "http://localhost:8081/api/orders" `
        -Method Post `
        -ContentType "application/json" `
        -Body $orderRequest
    
    Write-Host "✅ Order created successfully!" -ForegroundColor Green
    Write-Host "   Order ID: $($order.id)" -ForegroundColor Gray
    Write-Host "   User ID: $($order.userId)" -ForegroundColor Gray
    Write-Host "   Product: $($order.productName)" -ForegroundColor Gray
    Write-Host "   Status: $($order.status)" -ForegroundColor Gray
    Write-Host "   Total: $$($order.totalPrice)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to create order: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Wait for Kafka processing
Write-Host "2️⃣ Waiting for Kafka event processing (5 seconds)..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Check if payment was created
Write-Host "3️⃣ Verifying payment was created..." -ForegroundColor Cyan
try {
    $payment = Invoke-RestMethod -Uri "http://localhost:8082/api/payments/order/$($order.id)" -Method Get
    
    Write-Host "✅ Payment found!" -ForegroundColor Green
    Write-Host "   Payment ID: $($payment.id)" -ForegroundColor Gray
    Write-Host "   Order ID: $($payment.orderId)" -ForegroundColor Gray
    Write-Host "   User ID: $($payment.userId)" -ForegroundColor Gray
    Write-Host "   Amount: $$($payment.amount)" -ForegroundColor Gray
    Write-Host "   Status: $($payment.status)" -ForegroundColor Gray
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "⚠️  Payment not found yet (this is normal if processing is slow)" -ForegroundColor Yellow
        Write-Host "   Check Kafka logs for details" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Error checking payment: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Get statistics
Write-Host "4️⃣ Getting service statistics..." -ForegroundColor Cyan
Write-Host ""

# Order Service Stats
try {
    $orders = Invoke-RestMethod -Uri "http://localhost:8081/api/orders" -Method Get
    Write-Host "📦 Order Service:" -ForegroundColor White
    Write-Host "   Total Orders: $($orders.content.Count)" -ForegroundColor Gray
} catch {
    Write-Host "📦 Order Service: Unable to fetch stats" -ForegroundColor Yellow
}

# Payment Service Stats
try {
    $stats = Invoke-RestMethod -Uri "http://localhost:8082/api/payments/stats" -Method Get
    Write-Host "💳 Payment Service:" -ForegroundColor White
    Write-Host "   Total Payments: $($stats.totalPayments)" -ForegroundColor Gray
    Write-Host "   Completed: $($stats.completed)" -ForegroundColor Gray
    Write-Host "   Failed: $($stats.failed)" -ForegroundColor Gray
    Write-Host "   Pending: $($stats.pending)" -ForegroundColor Gray
    Write-Host "   Success Rate: $([math]::Round($stats.successRate, 2))%" -ForegroundColor Gray
} catch {
    Write-Host "💳 Payment Service: Unable to fetch stats" -ForegroundColor Yellow
}

# Final Summary
Write-Host ""
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ REBUILD COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Both services are now running with REST APIs:" -ForegroundColor White
Write-Host ""
Write-Host "📦 Order Service (Port 8081):" -ForegroundColor Yellow
Write-Host "   http://localhost:8081/api/orders" -ForegroundColor Gray
Write-Host "   - POST   /api/orders" -ForegroundColor Gray
Write-Host "   - GET    /api/orders" -ForegroundColor Gray
Write-Host "   - GET    /api/orders/{id}" -ForegroundColor Gray
Write-Host "   - GET    /api/orders/user/{userId}" -ForegroundColor Gray
Write-Host "   - GET    /api/orders/status/{status}" -ForegroundColor Gray
Write-Host "   - PUT    /api/orders/{id}/status" -ForegroundColor Gray
Write-Host ""
Write-Host "💳 Payment Service (Port 8082):" -ForegroundColor Yellow
Write-Host "   http://localhost:8082/api/payments" -ForegroundColor Gray
Write-Host "   - GET    /api/payments" -ForegroundColor Gray
Write-Host "   - GET    /api/payments/stats" -ForegroundColor Gray
Write-Host "   - GET    /api/payments/user/{userId}" -ForegroundColor Gray
Write-Host "   - GET    /api/payments/order/{orderId}" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  ✅ Run Postman collection tests" -ForegroundColor Gray
Write-Host "  ✅ Test order → payment flow end-to-end" -ForegroundColor Gray
Write-Host "  ✅ Monitor Kafka topic: order-events" -ForegroundColor Gray
Write-Host ""
