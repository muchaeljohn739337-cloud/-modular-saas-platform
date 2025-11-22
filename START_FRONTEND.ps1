# Start Frontend Server Script
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          Advancia Pay - Frontend Server Launcher          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Set-Location "C:\Users\mucha.DESKTOP-H7T9NPM\-modular-saas-platform\frontend"

Write-Host "📂 Working Directory: $(Get-Location)" -ForegroundColor Green
Write-Host "🚀 Starting Next.js Development Server on port 3000...`n" -ForegroundColor Yellow

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "⚠️  IMPORTANT: Keep this window open!" -ForegroundColor Red
Write-Host "   Closing this window will stop the frontend server." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray

npm run dev

Write-Host "`n❌ Frontend server stopped." -ForegroundColor Red
pause
