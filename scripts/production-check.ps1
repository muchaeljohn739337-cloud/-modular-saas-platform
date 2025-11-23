#!/usr/bin/env pwsh
# Production Launch Readiness Check
# Run before deploying to Digital Ocean

Write-Host "🚀 ADVANCIA PAY - PRODUCTION LAUNCH CHECKLIST" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$global:issuesFound = 0

function Test-Item {
    param($Name, $Check, $Fix)
    Write-Host "📋 Checking: $Name" -ForegroundColor Yellow
    if (& $Check) {
        Write-Host "   ✅ PASS" -ForegroundColor Green
        return $true
    } else {
        Write-Host "   ❌ FAIL" -ForegroundColor Red
        if ($Fix) { Write-Host "   💡 Fix: $Fix" -ForegroundColor Cyan }
        $global:issuesFound++
        return $false
    }
}

# 1. Environment Variables
Write-Host "`n🔐 ENVIRONMENT VARIABLES" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "Backend .env exists" {
    Test-Path "backend\.env"
} "Create backend/.env from backend/.env.example"

Test-Item "Frontend .env.local exists" {
    Test-Path "frontend\.env.local"
} "Create frontend/.env.local from frontend/.env.example"

$backendEnv = Get-Content "backend\.env" -Raw -ErrorAction SilentlyContinue
if ($backendEnv) {
    Test-Item "DATABASE_URL configured" {
        $backendEnv -match "DATABASE_URL=postgresql://"
    } "Set DATABASE_URL to your production PostgreSQL connection string"
    
    Test-Item "JWT_SECRET set (64+ chars)" {
        $secret = ($backendEnv | Select-String "JWT_SECRET=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value })
        $secret -and $secret.Length -ge 64
    } "Run: npm run gen:secret"
    
    Test-Item "STRIPE_SECRET_KEY set" {
        $backendEnv -match "STRIPE_SECRET_KEY=sk_" -and $backendEnv -notmatch "YOUR_NEW"
    } "Get from: https://dashboard.stripe.com/test/apikeys"
    
    Test-Item "STRIPE_WEBHOOK_SECRET set" {
        $backendEnv -match "STRIPE_WEBHOOK_SECRET=whsec_" -and $backendEnv -notmatch "YOUR_NEW"
    } "Create webhook endpoint in Stripe Dashboard"
    
    Test-Item "EMAIL credentials set" {
        $backendEnv -match "GMAIL_APP_PASSWORD=" -and $backendEnv -notmatch "YOUR_"
    } "Generate Gmail App Password: https://myaccount.google.com/apppasswords"
}

# 2. Database
Write-Host "`n💾 DATABASE" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "Prisma schema exists" {
    Test-Path "backend\prisma\schema.prisma"
} "Check Prisma setup"

Test-Item "Migrations directory exists" {
    Test-Path "backend\prisma\migrations"
} "Run: npx prisma migrate dev"

# 3. Dependencies
Write-Host "`n📦 DEPENDENCIES" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "Backend node_modules installed" {
    Test-Path "backend\node_modules"
} "Run: cd backend && npm install"

Test-Item "Frontend node_modules installed" {
    Test-Path "frontend\node_modules"
} "Run: cd frontend && npm install"

# 4. Build Check
Write-Host "`n🔨 BUILD VERIFICATION" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "Backend TypeScript compiles" {
    Push-Location backend
    $result = (npm run build 2>&1 | Out-String) -notmatch "error TS"
    Pop-Location
    $result
} "Fix TypeScript errors in backend"

Test-Item "Frontend builds successfully" {
    Push-Location frontend
    $result = (npm run build 2>&1 | Out-String) -notmatch "Failed to compile"
    Pop-Location
    $result
} "Fix Next.js build errors in frontend"

# 5. Tests
Write-Host "`n🧪 TESTS" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "Backend tests pass" {
    Push-Location backend
    $result = (npm test 2>&1 | Out-String) -match "Tests:.*passed"
    Pop-Location
    $result
} "Fix failing tests: cd backend && npm test"

# 6. Security Scan
Write-Host "`n🔒 SECURITY SCAN" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "No hardcoded secrets in code" {
    $secrets = git grep -i "sk_live_\|pk_live_" -- "*.ts" "*.tsx" "*.js" "*.jsx" 2>$null | 
               Where-Object { $_ -notmatch "test|mock|generate-secrets" }
    -not $secrets
} "Remove hardcoded secrets from source code"

Test-Item "No .env files in git" {
    $envInGit = git ls-files | Select-String "\.env$"
    -not $envInGit
} "Remove .env from git: git rm --cached backend/.env"

Test-Item ".gitignore includes .env" {
    $gitignore = Get-Content ".gitignore" -Raw -ErrorAction SilentlyContinue
    $gitignore -match "\.env"
} "Add .env to .gitignore"

# 7. Stripe Configuration
Write-Host "`n💳 STRIPE SETUP" -ForegroundColor Magenta
Write-Host "-" * 60

Write-Host "   ⚠️  Manual checks required:" -ForegroundColor Yellow
Write-Host "   1. Go to: https://dashboard.stripe.com/products" -ForegroundColor Cyan
Write-Host "   2. Verify 'Advancia Pay Pro' product exists ($10/month)" -ForegroundColor Cyan
Write-Host "   3. Copy Price ID (starts with price_) to .env" -ForegroundColor Cyan
Write-Host "   4. Create webhook endpoint pointing to your backend" -ForegroundColor Cyan

# 8. Deployment Readiness
Write-Host "`n🌐 DEPLOYMENT READINESS" -ForegroundColor Magenta
Write-Host "-" * 60

Test-Item "PM2 ecosystem.config.js exists" {
    Test-Path "ecosystem.config.js"
} "Create PM2 config for production process management"

Test-Item "Docker setup exists" {
    Test-Path "docker-compose.yml"
} "Optional: Docker setup for local testing"

# Summary
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
if ($global:issuesFound -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED - READY TO DEPLOY!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Create Digital Ocean Droplet ($12/month)" -ForegroundColor White
    Write-Host "2. SSH into server and clone repo" -ForegroundColor White
    Write-Host "3. Copy .env files to server" -ForegroundColor White
    Write-Host "4. Run: npm run build && pm2 start ecosystem.config.js" -ForegroundColor White
    Write-Host "5. Deploy frontend to Vercel" -ForegroundColor White
    Write-Host "6. Update NEXT_PUBLIC_API_URL with droplet IP" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "❌ FOUND $global:issuesFound ISSUE(S) - FIX BEFORE DEPLOYING" -ForegroundColor Red
    Write-Host ""
    Write-Host "Review the failures above and run this script again" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
