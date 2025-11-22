<#!
Purpose: Developer convenience script to install dependencies, apply migrations, start backend & frontend, and run production verification.
Run: pwsh -ExecutionPolicy Bypass -File scripts/launch-dev.ps1 [-SkipInstall] [-SkipVerify]
!>
param(
    [switch]$SkipInstall,
    [switch]$SkipVerify,
    [switch]$Detached
)

$ErrorActionPreference = 'Stop'
function WriteStep($msg) { Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function WriteOk($msg) { Write-Host "[OK]   $msg" -ForegroundColor Green }
function WriteWarn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function WriteErr($msg) { Write-Host "[ERR]  $msg" -ForegroundColor Red }

# Root sanity
WriteStep "Verifying directory layout"
if (!(Test-Path -Path "backend" -PathType Container)) { WriteErr "Missing backend/ directory"; exit 1 }
if (!(Test-Path -Path "frontend" -PathType Container)) { WriteErr "Missing frontend/ directory"; exit 1 }
WriteOk "Found backend/ and frontend/"

# Environment pre-check
WriteStep "Checking minimal env vars"
$required = @('DATABASE_URL','JWT_SECRET','JWT_REFRESH_SECRET')
$missing = @()
foreach ($v in $required) { if (-not $env:$v) { $missing += $v } }
if ($missing.Count -gt 0) { WriteWarn "Missing env vars: $($missing -join ', ') (development will still start, but set them before production)" } else { WriteOk "Core env vars present" }

# Install deps
if (-not $SkipInstall) {
  WriteStep "Installing backend dependencies"
  Push-Location backend
  npm install --no-audit --no-fund
  WriteOk "Backend dependencies installed"
  Pop-Location

  WriteStep "Installing frontend dependencies"
  Push-Location frontend
  npm install --no-audit --no-fund
  WriteOk "Frontend dependencies installed"
  Pop-Location
} else { WriteWarn "Skipping dependency installation (--SkipInstall)" }

# Apply migrations
WriteStep "Applying Prisma migrations"
Push-Location backend
try {
  npx prisma migrate deploy
  WriteOk "Migrations applied"
} catch {
  WriteErr "Migration failure: $_"; Pop-Location; exit 1
}
Pop-Location

# Start backend
WriteStep "Starting backend dev server"
$backendCmd = "npm run dev"
if ($Detached) {
  Start-Process pwsh -ArgumentList "-NoLogo","-Command","cd `"$PWD/backend`"; $backendCmd" -WindowStyle Minimized
  WriteOk "Backend started detached"
} else {
  $backendJob = Start-Job -ScriptBlock { cd backend; npm run dev }
  WriteOk "Backend started in background job Id=$($backendJob.Id)"
}

# Wait briefly for backend health
Start-Sleep -Seconds 4
try {
  $health = Invoke-RestMethod -Uri "http://localhost:4000/health" -Method GET -TimeoutSec 5
  WriteOk "Backend health: $($health.status)"
} catch { WriteWarn "Backend health check failed (may still be starting): $_" }

# Start frontend
WriteStep "Starting frontend dev server"
$frontendCmd = "npm run dev"
if ($Detached) {
  Start-Process pwsh -ArgumentList "-NoLogo","-Command","cd `"$PWD/frontend`"; $frontendCmd" -WindowStyle Minimized
  WriteOk "Frontend started detached"
} else {
  $frontendJob = Start-Job -ScriptBlock { cd frontend; npm run dev }
  WriteOk "Frontend started in background job Id=$($frontendJob.Id)"
}

# Optional production verification
if (-not $SkipVerify) {
  WriteStep "Running production verification suite"
  try {
    Push-Location backend
    if (Test-Path scripts\verify-production.ts) {
      WriteWarn "Custom verification script detected; ensure build prerequisites are met."
    }
    npm run verify:production
    WriteOk "Verification script finished"
    Pop-Location
  } catch { WriteWarn "Verification failed: $_" }
} else { WriteWarn "Skipping verification (--SkipVerify)" }

WriteOk "Launch sequence complete"
WriteStep "Next actions: Test payment flows, enable commented routes, configure live Stripe keys when ready."
