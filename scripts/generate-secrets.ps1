# Generate Secure Environment Variables for Render Deployment
# Run this script to generate all required secrets

Write-Host "🔐 Generating Secure Environment Variables for Advancia Pay" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""

# Function to generate random secure string
function New-SecureSecret {
    param (
        [int]$Length = 64
    )
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?'
    $random = 1..$Length | ForEach-Object { Get-Random -Maximum $chars.Length }
    -join ($random | ForEach-Object { $chars[$_] })
}

# Function to generate hex string (for encryption keys)
function New-HexKey {
    param (
        [int]$Bytes = 32
    )
    $randomBytes = New-Object byte[] $Bytes
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($randomBytes)
    [System.BitConverter]::ToString($randomBytes).Replace("-", "").ToLower()
}

# Function to generate base64 string (for IV)
function New-Base64Key {
    param (
        [int]$Bytes = 16
    )
    $randomBytes = New-Object byte[] $Bytes
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($randomBytes)
    [Convert]::ToBase64String($randomBytes)
}

Write-Host "📋 COPY THESE VALUES TO RENDER DASHBOARD" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""

# Generate and display secrets
Write-Host "1️⃣  JWT_SECRET" -ForegroundColor Green
$jwtSecret = New-SecureSecret -Length 64
Write-Host "   $jwtSecret" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  SESSION_SECRET" -ForegroundColor Green
$sessionSecret = New-SecureSecret -Length 64
Write-Host "   $sessionSecret" -ForegroundColor White
Write-Host ""

Write-Host "3️⃣  JWT_SECRET_ENCRYPTED" -ForegroundColor Green
$jwtSecretEncrypted = New-SecureSecret -Length 64
Write-Host "   $jwtSecretEncrypted" -ForegroundColor White
Write-Host ""

Write-Host "4️⃣  JWT_ENCRYPTION_KEY (32 bytes hex)" -ForegroundColor Green
$jwtEncryptionKey = New-HexKey -Bytes 32
Write-Host "   $jwtEncryptionKey" -ForegroundColor White
Write-Host ""

Write-Host "5️⃣  JWT_ENCRYPTION_IV (16 bytes base64)" -ForegroundColor Green
$jwtEncryptionIv = New-Base64Key -Bytes 16
Write-Host "   $jwtEncryptionIv" -ForegroundColor White
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "🔑 VAPID KEYS (Web Push Notifications)" -ForegroundColor Cyan
Write-Host "   Run this command to generate VAPID keys:" -ForegroundColor Yellow
Write-Host "   cd backend && npx web-push generate-vapid-keys" -ForegroundColor White
Write-Host ""
Write-Host "   Then copy the output here:" -ForegroundColor Yellow
Write-Host "   6️⃣  VAPID_PUBLIC_KEY: [paste from command output]" -ForegroundColor Green
Write-Host "   7️⃣  VAPID_PRIVATE_KEY: [paste from command output]" -ForegroundColor Green
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "💳 STRIPE KEYS" -ForegroundColor Cyan
Write-Host "   Get these from: https://dashboard.stripe.com/test/apikeys" -ForegroundColor Yellow
Write-Host ""
Write-Host "   8️⃣  STRIPE_SECRET_KEY: sk_test_... [from Stripe Dashboard]" -ForegroundColor Green
Write-Host "   9️⃣  STRIPE_PUBLISHABLE_KEY: pk_test_... [from Stripe Dashboard]" -ForegroundColor Green
Write-Host ""
Write-Host "   Get webhook secret from: https://dashboard.stripe.com/test/webhooks" -ForegroundColor Yellow
Write-Host "   🔟 STRIPE_WEBHOOK_SECRET: whsec_... [from Stripe Webhook Settings]" -ForegroundColor Green
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "₿ CRYPTOMUS KEYS (Crypto Payments)" -ForegroundColor Cyan
Write-Host "   Get these from: https://cryptomus.com/dashboard" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1️⃣1️⃣ CRYPTOMUS_API_KEY: [from Cryptomus Dashboard]" -ForegroundColor Green
Write-Host "   1️⃣2️⃣ CRYPTOMUS_MERCHANT_ID: [from Cryptomus Dashboard]" -ForegroundColor Green
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "🐛 SENTRY (Error Tracking)" -ForegroundColor Cyan
Write-Host "   Get this from: https://sentry.io/settings/projects/" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1️⃣3️⃣ SENTRY_DSN: https://...@sentry.io/... [from Sentry Project Settings]" -ForegroundColor Green
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "📧 EMAIL (Gmail SMTP)" -ForegroundColor Cyan
Write-Host "   Setup Gmail App Password: https://myaccount.google.com/apppasswords" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1️⃣4️⃣ EMAIL_USER: your-email@gmail.com" -ForegroundColor Green
Write-Host "   1️⃣5️⃣ EMAIL_PASSWORD: [16-char app password from Gmail]" -ForegroundColor Green
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "✅ AUTO-CONFIGURED (Already in render.yaml)" -ForegroundColor Green
Write-Host "   These are automatically set from your Render database:" -ForegroundColor Gray
Write-Host "   - DATABASE_URL (from Render PostgreSQL)" -ForegroundColor Gray
Write-Host "   - NODE_ENV=production" -ForegroundColor Gray
Write-Host "   - PORT=4000" -ForegroundColor Gray
Write-Host "   - FRONTEND_URL=https://your-app.vercel.app" -ForegroundColor Gray
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "📝 QUICK COPY FORMAT (for Render Dashboard)" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""

# Create .env.render file for easy reference
$envContent = @"
# Generated Secrets - DO NOT COMMIT TO GIT
# Copy these values to Render Dashboard manually

# Auth & Security
JWT_SECRET=$jwtSecret
SESSION_SECRET=$sessionSecret
JWT_SECRET_ENCRYPTED=$jwtSecretEncrypted
JWT_ENCRYPTION_KEY=$jwtEncryptionKey
JWT_ENCRYPTION_IV=$jwtEncryptionIv

# VAPID Keys (generate with: cd backend && npx web-push generate-vapid-keys)
VAPID_PUBLIC_KEY=<paste_from_web-push_command>
VAPID_PRIVATE_KEY=<paste_from_web-push_command>

# Stripe (get from: https://dashboard.stripe.com/test/apikeys)
STRIPE_SECRET_KEY=sk_test_<your_key_here>
STRIPE_PUBLISHABLE_KEY=pk_test_<your_key_here>
STRIPE_WEBHOOK_SECRET=whsec_<your_webhook_secret>

# Cryptomus (get from: https://cryptomus.com/dashboard)
CRYPTOMUS_API_KEY=<your_api_key>
CRYPTOMUS_MERCHANT_ID=<your_merchant_id>

# Sentry (get from: https://sentry.io/settings/projects/)
SENTRY_DSN=<your_sentry_dsn>

# Email (Gmail App Password: https://myaccount.google.com/apppasswords)
EMAIL_USER=<your_email@gmail.com>
EMAIL_PASSWORD=<your_gmail_app_password>

# Note: DATABASE_URL, NODE_ENV, PORT are auto-configured by Render
"@

$envFilePath = Join-Path $PSScriptRoot ".." ".env.render.generated"
$envContent | Out-File -FilePath $envFilePath -Encoding UTF8

Write-Host "💾 Saved to: .env.render.generated" -ForegroundColor Green
Write-Host "   (This file is gitignored for security)" -ForegroundColor Gray
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Generate VAPID keys:" -ForegroundColor Yellow
Write-Host "   cd backend && npx web-push generate-vapid-keys" -ForegroundColor White
Write-Host ""
Write-Host "2. Copy all values to Render Dashboard:" -ForegroundColor Yellow
Write-Host "   https://dashboard.render.com → advancia-backend → Environment" -ForegroundColor White
Write-Host ""
Write-Host "3. Get external service keys:" -ForegroundColor Yellow
Write-Host "   - Stripe: https://dashboard.stripe.com/test/apikeys" -ForegroundColor White
Write-Host "   - Cryptomus: https://cryptomus.com/dashboard" -ForegroundColor White
Write-Host "   - Sentry: https://sentry.io" -ForegroundColor White
Write-Host "   - Gmail: https://myaccount.google.com/apppasswords" -ForegroundColor White
Write-Host ""
Write-Host "4. Click 'Deploy Blueprint' in Render Dashboard" -ForegroundColor Yellow
Write-Host ""
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Script completed! Check .env.render.generated file" -ForegroundColor Green
Write-Host ""
