#!/usr/bin/env bash
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Ensure Node.js is installed." >&2
  exit 1
fi

echo "Running Prisma migrations in deploy mode..."
npx prisma migrate deploy
echo "Migrations applied successfully."
