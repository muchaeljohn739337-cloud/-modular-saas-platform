# Systematic Render Deployment Monitor
# Checks deployment status step-by-step

param(
    [int]$MaxAttempts = 20,
    [int]$WaitSeconds = 15
)

Write-Host "🚀 Systematic Render Deployment Monitor" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host ""

$backendUrl = "https://advancia-backend.onrender.com"
$healthEndpoint = "$backendUrl/api/health"

Write-Host "📍 Target Backend: $backendUrl" -ForegroundColor White
Write-Host "🔍 Monitoring for: $($MaxAttempts * $WaitSeconds) seconds max" -ForegroundColor Gray
Write-Host ""

# Step 1: Check if service exists
Write-Host "Step 1: Checking if Render service exists..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $backendUrl -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
    Write-Host "✅ Service exists (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 502) {
        Write-Host "⚠️  Service exists but not ready (502 Bad Gateway)" -ForegroundColor Yellow
        Write-Host "   This is normal during deployment - backend is building..." -ForegroundColor Gray
    } elseif ($statusCode -eq 404) {
        Write-Host "❌ Service not found (404)" -ForegroundColor Red
        Write-Host "   Check: https://dashboard.render.com" -ForegroundColor Yellow
        Write-Host "   Ensure 'Deploy Blueprint' was clicked" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "⚠️  Service responding with status: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 2: Monitor health endpoint
Write-Host "Step 2: Monitoring health endpoint..." -ForegroundColor Yellow
Write-Host "   Endpoint: $healthEndpoint" -ForegroundColor Gray
Write-Host ""

$attempt = 0
$deployed = $false

while ($attempt -lt $MaxAttempts -and -not $deployed) {
    $attempt++
    $elapsed = $attempt * $WaitSeconds
    
    Write-Host "[$attempt/$MaxAttempts] Checking... (${elapsed}s elapsed)" -ForegroundColor Cyan -NoNewline
    
    try {
        $response = Invoke-RestMethod -Uri $healthEndpoint -Method GET -TimeoutSec 10 -ErrorAction Stop
        
        Write-Host " ✅ SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host "🎉 DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Health Check Response:" -ForegroundColor Cyan
        Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor White
        Write-Host ""
        
        $deployed = $true
        
        # Step 3: Verify key components
        Write-Host "Step 3: Verifying components..." -ForegroundColor Yellow
        Write-Host ""
        
        if ($response.status -eq "ok") {
            Write-Host "   ✅ Server Status: OK" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Server Status: $($response.status)" -ForegroundColor Yellow
        }
        
        if ($response.database) {
            Write-Host "   ✅ Database: $($response.database)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Database status unknown" -ForegroundColor Yellow
        }
        
        if ($response.timestamp) {
            Write-Host "   ✅ Timestamp: $($response.timestamp)" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "=" * 70 -ForegroundColor Gray
        Write-Host ""
        
        # Next steps
        Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Test additional endpoints:" -ForegroundColor Yellow
        Write-Host "   Invoke-WebRequest -Uri '$backendUrl/api/auth/health'" -ForegroundColor White
        Write-Host ""
        Write-Host "2. Configure Vercel frontend:" -ForegroundColor Yellow
        Write-Host "   - Go to: https://vercel.com/dashboard" -ForegroundColor White
        Write-Host "   - Add environment variable:" -ForegroundColor White
        Write-Host "     NEXT_PUBLIC_API_URL=$backendUrl" -ForegroundColor White
        Write-Host ""
        Write-Host "3. View deployment logs:" -ForegroundColor Yellow
        Write-Host "   https://dashboard.render.com → advancia-backend → Logs" -ForegroundColor White
        Write-Host ""
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        
        if ($statusCode -eq 502) {
            Write-Host " ⏳ Building... (502)" -ForegroundColor Yellow
        } elseif ($statusCode -eq 503) {
            Write-Host " ⏳ Starting... (503)" -ForegroundColor Yellow
        } elseif ($statusCode -eq 404) {
            Write-Host " ❌ Not Found (404)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Service endpoint not found. Possible issues:" -ForegroundColor Red
            Write-Host "- Deployment hasn't started yet" -ForegroundColor Yellow
            Write-Host "- Service name mismatch in render.yaml" -ForegroundColor Yellow
            Write-Host "- Build failed (check Render logs)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Check: https://dashboard.render.com → advancia-backend → Logs" -ForegroundColor Cyan
            break
        } else {
            Write-Host " ⚠️  Error: $statusCode" -ForegroundColor Yellow
        }
        
        if ($attempt -lt $MaxAttempts) {
            Write-Host "   Waiting ${WaitSeconds}s..." -ForegroundColor Gray
            Start-Sleep -Seconds $WaitSeconds
        }
    }
}

if (-not $deployed) {
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor Red
    Write-Host "⏱️  Timeout: Backend not ready after $($MaxAttempts * $WaitSeconds) seconds" -ForegroundColor Red
    Write-Host "=" * 70 -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Troubleshooting Steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Check Render Dashboard Logs:" -ForegroundColor Cyan
    Write-Host "   https://dashboard.render.com" -ForegroundColor White
    Write-Host "   → Click 'advancia-backend'" -ForegroundColor White
    Write-Host "   → Click 'Logs' tab" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Look for these errors:" -ForegroundColor Cyan
    Write-Host "   - Build failed" -ForegroundColor White
    Write-Host "   - Prisma migration failed" -ForegroundColor White
    Write-Host "   - Missing environment variable" -ForegroundColor White
    Write-Host "   - Port binding error" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Common fixes:" -ForegroundColor Cyan
    Write-Host "   - Verify all 15 environment variables are set" -ForegroundColor White
    Write-Host "   - Check DATABASE_URL is configured" -ForegroundColor White
    Write-Host "   - Restart deployment from Render dashboard" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Continue monitoring:" -ForegroundColor Cyan
    Write-Host "   .\scripts\monitor-render-deployment.ps1 -MaxAttempts 30" -ForegroundColor White
    Write-Host ""
    
    exit 1
}

Write-Host "✅ Systematic deployment check complete!" -ForegroundColor Green
Write-Host ""
