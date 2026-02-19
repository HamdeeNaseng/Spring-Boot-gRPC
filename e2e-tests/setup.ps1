#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick setup script for Playwright E2E tests

.DESCRIPTION
    Installs all dependencies and sets up Playwright browsers

.EXAMPLE
    .\setup.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🚀 Playwright E2E Tests Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to test directory
Set-Location "$PSScriptRoot"

# Step 1: Install npm dependencies
Write-Host "📦 Step 1/2: Installing npm dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ npm install failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 2: Install Playwright browsers
Write-Host "🌐 Step 2/2: Installing Playwright browsers..." -ForegroundColor Yellow
npx playwright install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Playwright install failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Playwright browsers installed" -ForegroundColor Green
Write-Host ""

# Done
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Start services: cd .. ; docker-compose up -d" -ForegroundColor Gray
Write-Host "  2. Run tests: .\run-tests.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Available test commands:" -ForegroundColor White
Write-Host "  npm test                  - Run all tests" -ForegroundColor Gray
Write-Host "  npm run test:order        - Order Service tests" -ForegroundColor Gray
Write-Host "  npm run test:payment      - Payment Service tests" -ForegroundColor Gray
Write-Host "  npm run test:e2e          - Integration tests" -ForegroundColor Gray
Write-Host "  npm run test:ui           - Interactive UI mode" -ForegroundColor Gray
Write-Host "  npm run test:report       - View last test report" -ForegroundColor Gray
Write-Host ""
