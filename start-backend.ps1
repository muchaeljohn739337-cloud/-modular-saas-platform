# Backend Startup Script with ts-node Cache Bypass
# Addresses persistent caching issues and ensures clean startup

param(
    [switch]$Clean = $false,
    [switch]$Debug = $false
)

$ErrorActionPreference = "Continue"
$backendDir = "C:\Users\mucha.DESKTOP-H7T9NPM\-modular-saas-platform\backend"

Write-Host "`n🚀 Advancia Backend Startup Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Navigate to backend directory
Set-Location $backendDir

# Step 1: Kill existing processes
Write-Host "`n🛑 Stopping existing processes..." -ForegroundColor Yellow
Stop-Process -Name "node","nodemon" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Clean cache if requested
if ($Clean) {
    Write-Host "`n🧹 Cleaning caches..." -ForegroundColor Yellow
    Remove-Item -Path ".ts-node" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "tsconfig.tsbuildinfo" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "node_modules/.cache" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Caches cleared" -ForegroundColor Green
}

# Step 3: Verify critical files exist
Write-Host "`n📋 Verifying files..." -ForegroundColor Yellow
$criticalFiles = @(
    "src/index.ts",
    "src/routes/trust.ts",
    "src/routes/trustpilot.ts",
    "src/services/scamAdviserService.ts",
    "src/services/trustpilotInvitationService.ts",
    "package.json",
    ".env"
)

$missing = @()
foreach ($file in $criticalFiles) {
    if (-not (Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "❌ Missing critical files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "✓ All critical files present" -ForegroundColor Green

# Step 4: Check environment variables
Write-Host "`n🔐 Checking environment..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Warning: .env file not found. Using .env.example" -ForegroundColor Yellow
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
    }
}
Write-Host "✓ Environment configured" -ForegroundColor Green

# Step 5: Verify database connection
Write-Host "`n💾 Checking database..." -ForegroundColor Yellow
$env:NODE_ENV = "development"
$dbCheck = npx prisma db execute --stdin --schema=prisma/schema.prisma --command "SELECT 1" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Database connection successful" -ForegroundColor Green
} else {
    Write-Host "⚠️  Database connection failed - server will attempt to connect on startup" -ForegroundColor Yellow
}

# Step 6: Generate Prisma client if needed
Write-Host "`n🔧 Checking Prisma client..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules/.prisma")) {
    Write-Host "Generating Prisma client..." -ForegroundColor Gray
    npx prisma generate
    Write-Host "✓ Prisma client generated" -ForegroundColor Green
} else {
    Write-Host "✓ Prisma client ready" -ForegroundColor Green
}

# Step 7: Start server
Write-Host "`n🌟 Starting backend server..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if ($Debug) {
    # Debug mode - show all output
    Write-Host "Debug mode enabled - verbose output" -ForegroundColor Yellow
    $env:DEBUG = "*"
    npm run dev
} else {
    # Normal mode - start in background
    Write-Host "Starting server on http://localhost:4000" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available endpoints:" -ForegroundColor Cyan
    Write-Host "  • Health:      http://localhost:4000/api/health" -ForegroundColor White
    Write-Host "  • Trust:       http://localhost:4000/api/trust/report" -ForegroundColor White
    Write-Host "  • Trustpilot:  http://localhost:4000/api/trustpilot/stats" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
    Write-Host ""
    
    npm run dev
}

# Cleanup on exit
Write-Host "`n👋 Server stopped" -ForegroundColor Yellow
