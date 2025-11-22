param(
  [string]$DatabaseUrl
)

$ErrorActionPreference = 'Stop'

function Ensure-Command($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    Write-Error "Required command '$name' not found in PATH."
    exit 1
  }
}

Write-Host "Running Prisma migrations in deploy mode..." -ForegroundColor Cyan
Ensure-Command npx

if ($DatabaseUrl) {
  $env:DATABASE_URL = $DatabaseUrl
}

npx prisma migrate deploy

Write-Host "Migrations applied successfully." -ForegroundColor Green
