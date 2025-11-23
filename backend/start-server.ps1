# Start backend server and keep it running
Write-Host "🚀 Starting Advancia Backend Server..." -ForegroundColor Cyan
Write-Host "📍 Location: $(Get-Location)" -ForegroundColor Cyan
Write-Host "⚠️  Press Ctrl+C TWICE to stop the server" -ForegroundColor Yellow
Write-Host ""

# Set environment to development
$env:NODE_ENV = "development"

# Start the server
node dist/index.js
