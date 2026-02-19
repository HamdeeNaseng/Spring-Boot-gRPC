#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Rebuild and restart Payment Service with updated REST controller

.DESCRIPTION
    This script:
    1. Builds Payment Service JAR with Maven
    2. Rebuilds Docker image
    3. Restarts the service
    4. Runs health checks
    5. Tests REST endpoints

.EXAMPLE
    .\rebuild-payment-service.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "💳 Payment Service Rebuild Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build with Maven
Write-Host "🔨 Step 1/5: Building Payment Service with Maven..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot\payment-service"

try {
    if (Test-Path ".\mvnw.cmd") {
        Write-Host "Using Maven Wrapper..." -ForegroundColor Gray
        .\mvnw.cmd clean package -DskipTests
    } else {
        Write-Host "Using system Maven..." -ForegroundColor Gray
        mvn clean package -DskipTests
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "✅ Maven build successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven build failed: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Rebuild Docker image
Write-Host ""
Write-Host "🐳 Step 2/5: Rebuilding Docker image..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot"

try {
    docker-compose build --no-cache payment-service
    if ($LASTEXITCODE -ne 0) {
        throw "Docker build failed with exit code $LASTEXITCODE"
    }
    Write-Host "✅ Docker image rebuilt" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker build failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Restart the service
Write-Host ""
Write-Host "🔄 Step 3/5: Restarting Payment Service..." -ForegroundColor Yellow

try {
    docker-compose restart payment-service
    if ($LASTEXITCODE -ne 0) {
        throw "Docker restart failed with exit code $LASTEXITCODE"
    }
    Write-Host "✅ Service restarted" -ForegroundColor Green
} catch {
    Write-Host "❌ Service restart failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Wait for service to be ready
Write-Host ""
Write-Host "⏳ Step 4/5: Waiting for service to be healthy..." -ForegroundColor Yellow

$maxAttempts = 30
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts -and -not $healthy) {
    $attempt++
    Write-Host "Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8082/api/health" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            $healthy = $true
            Write-Host "✅ Service is healthy!" -ForegroundColor Green
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $healthy) {
    Write-Host "❌ Service did not become healthy in time" -ForegroundColor Red
    Write-Host "Check logs with: docker-compose logs payment-service" -ForegroundColor Yellow
    exit 1
}

# Step 5: Test REST endpoints
Write-Host ""
Write-Host "🧪 Step 5/5: Testing REST endpoints..." -ForegroundColor Yellow
Write-Host ""

# Test 1: Get all payments
Write-Host "Test 1: GET /api/payments (Get all payments)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8082/api/payments" -Method Get
    Write-Host "✅ Status: 200 OK" -ForegroundColor Green
    Write-Host "Response: Found $($response.Count) payments" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Get payment statistics
Write-Host "Test 2: GET /api/payments/stats (Get statistics)" -ForegroundColor Cyan
try {
    $stats = Invoke-RestMethod -Uri "http://localhost:8082/api/payments/stats" -Method Get
    Write-Host "✅ Status: 200 OK" -ForegroundColor Green
    Write-Host "Statistics:" -ForegroundColor Gray
    Write-Host "  Total Payments: $($stats.totalPayments)" -ForegroundColor Gray
    Write-Host "  Completed: $($stats.completed)" -ForegroundColor Gray
    Write-Host "  Failed: $($stats.failed)" -ForegroundColor Gray
    Write-Host "  Pending: $($stats.pending)" -ForegroundColor Gray
    Write-Host "  Success Rate: $([math]::Round($stats.successRate, 2))%" -ForegroundColor Gray
    Write-Host "  Total Amount: $$([math]::Round($stats.totalAmountProcessed, 2))" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Get payments by user (example user)
Write-Host "Test 3: GET /api/payments/user/test-user (Get by user ID)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8082/api/payments/user/test-user" -Method Get
    Write-Host "✅ Status: 200 OK" -ForegroundColor Green
    Write-Host "Response: Found $($response.Count) payments for user 'test-user'" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Payment Service Rebuild Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Service Status:" -ForegroundColor White
Write-Host "  🌐 REST API: http://localhost:8082" -ForegroundColor Gray
Write-Host "  📊 Health Check: http://localhost:8082/api/health" -ForegroundColor Gray
Write-Host "  💳 Payments API: http://localhost:8082/api/payments" -ForegroundColor Gray
Write-Host ""
Write-Host "Available Endpoints:" -ForegroundColor White
Write-Host "  GET /api/payments              - Get all payments" -ForegroundColor Gray
Write-Host "  GET /api/payments/stats        - Get payment statistics" -ForegroundColor Gray
Write-Host "  GET /api/payments/user/{id}    - Get payments by user ID" -ForegroundColor Gray
Write-Host "  GET /api/payments/order/{id}   - Get payment by order ID" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  1. Test endpoints manually or with Postman" -ForegroundColor Gray
Write-Host "  2. Create an order to trigger payment via Kafka" -ForegroundColor Gray
Write-Host "  3. Verify payment was created and processed" -ForegroundColor Gray
Write-Host ""
