Param(
  [string]$DatabaseUrl = $env:DATABASE_URL,
  [switch]$SkipMigrate,
  [switch]$SkipDBCheck
)

Write-Host "== Advancia Backend Dev Start ==" -ForegroundColor Cyan

if (-not $DatabaseUrl) {
  $DatabaseUrl = "postgres://postgres:postgres@localhost:5432/advancia_dev"
  Write-Host "DATABASE_URL not provided; using default $DatabaseUrl" -ForegroundColor Yellow
  $env:DATABASE_URL = $DatabaseUrl
}

if (-not $env:JWT_SECRET) {
  $env:JWT_SECRET = [Convert]::ToBase64String((New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes(48))
  Write-Host "Generated temporary JWT_SECRET" -ForegroundColor Yellow
}

Write-Host "Checking critical env vars..." -ForegroundColor Cyan
pnpm exec ts-node scripts/verify-env.ts
if ($LASTEXITCODE -ne 0) { Write-Host "Fix missing env vars before continuing." -ForegroundColor Red; exit 1 }

if (-not $SkipMigrate) {
  Write-Host "Running prisma migrate dev..." -ForegroundColor Cyan
  npx prisma migrate dev --name auto || { Write-Host "Migration failed." -ForegroundColor Red; exit 1 }
} else {
  Write-Host "Skipping migrations." -ForegroundColor Yellow
}

if (-not $SkipDBCheck) {
  Write-Host "Checking DB connectivity..." -ForegroundColor Cyan
  pnpm exec ts-node scripts/check-db.ts
  if ($LASTEXITCODE -ne 0) { Write-Host "DB check failed." -ForegroundColor Red; exit 1 }
} else {
  Write-Host "Skipping DB check." -ForegroundColor Yellow
}

Write-Host "Starting dev server (nodemon + ts-node)..." -ForegroundColor Green
pnpm run dev
