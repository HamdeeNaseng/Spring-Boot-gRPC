#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup and run Playwright E2E tests

.DESCRIPTION
    This script:
    1. Checks if services are running
    2. Installs dependencies
    3. Sets up Playwright
    4. Runs the test suite

.EXAMPLE
    .\run-tests.ps1
    .\run-tests.ps1 -TestSuite order
    .\run-tests.ps1 -Headed
#>

param(
    [string]$TestSuite = "all",  # all, order, payment, e2e
    [switch]$Headed = $false,
    [switch]$Debug = $false,
    [switch]$UI = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🧪 Playwright E2E Test Runner" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to test directory
Set-Location "$PSScriptRoot"

# Step 1: Check if services are running
Write-Host "🔍 Step 1/4: Checking if services are running..." -ForegroundColor Yellow
Write-Host ""

$orderServiceUp = $false
$paymentServiceUp = $false

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/api/health" -UseBasicParsing -TimeoutSec 3
    if ($response.StatusCode -eq 200) {
        $orderServiceUp = $true
        Write-Host "✅ Order Service is running (Port 8081)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Order Service is NOT running (Port 8081)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/health" -UseBasicParsing -TimeoutSec 3
    if ($response.StatusCode -eq 200) {
        $paymentServiceUp = $true
        Write-Host "✅ Payment Service is running (Port 8082)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Payment Service is NOT running (Port 8082)" -ForegroundColor Red
}

if (-not $orderServiceUp -or -not $paymentServiceUp) {
    Write-Host ""
    Write-Host "⚠️  Services are not running!" -ForegroundColor Yellow
    Write-Host "Please start services with:" -ForegroundColor Yellow
    Write-Host "  cd .." -ForegroundColor Gray
    Write-Host "  docker-compose up -d" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""

# Step 2: Install dependencies
Write-Host "📦 Step 2/4: Installing dependencies..." -ForegroundColor Yellow

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing npm packages..." -ForegroundColor Gray
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ npm install failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
}

Write-Host ""

# Step 3: Install Playwright browsers
Write-Host "🌐 Step 3/4: Setting up Playwright..." -ForegroundColor Yellow

if (-not (Test-Path "$env:USERPROFILE\.cache\ms-playwright")) {
    Write-Host "Installing Playwright browsers..." -ForegroundColor Gray
    npx playwright install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Playwright install failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Playwright browsers installed" -ForegroundColor Green
} else {
    Write-Host "✅ Playwright already set up" -ForegroundColor Green
}

Write-Host ""

# Step 4: Run tests
Write-Host "🧪 Step 4/4: Running tests..." -ForegroundColor Yellow
Write-Host ""

# Determine which tests to run
$testCommand = "npx playwright test"

if ($UI) {
    $testCommand += " --ui"
} elseif ($Debug) {
    $testCommand += " --debug"
} elseif ($Headed) {
    $testCommand += " --headed"
}

switch ($TestSuite.ToLower()) {
    "order" {
        Write-Host "Running Order Service tests only..." -ForegroundColor Cyan
        $testCommand += " tests/order-service.spec.ts"
    }
    "payment" {
        Write-Host "Running Payment Service tests only..." -ForegroundColor Cyan
        $testCommand += " tests/payment-service.spec.ts"
    }
    "e2e" {
        Write-Host "Running E2E Integration tests only..." -ForegroundColor Cyan
        $testCommand += " tests/e2e-flow.spec.ts"
    }
    default {
        Write-Host "Running all tests..." -ForegroundColor Cyan
    }
}

Write-Host "Command: $testCommand" -ForegroundColor Gray
Write-Host ""

Invoke-Expression $testCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "✅ Tests Completed Successfully!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "View test report:" -ForegroundColor White
    Write-Host "  npm run test:report" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "❌ Tests Failed!" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "View detailed report:" -ForegroundColor White
    Write-Host "  npm run test:report" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
