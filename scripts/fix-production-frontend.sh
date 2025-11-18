#!/bin/bash
# Fix Production Frontend and Apply Wallet Migration

set -e

echo "=== Stopping frontend to prevent continuous crashes ==="
pm2 stop advancia-frontend || true

echo "=== Cleaning corrupted node_modules ==="
cd /var/www/advancia/frontend
rm -rf node_modules package-lock.json .next

echo "=== Reinstalling frontend dependencies ==="
npm cache clean --force
npm install --legacy-peer-deps

echo "=== Building frontend ==="
npm run build

echo "=== Restarting frontend with PM2 ==="
pm2 restart advancia-frontend || pm2 start npm --name "advancia-frontend" -- start

echo "=== Applying wallet migration to database ==="
cd /var/www/advancia/backend
psql $DATABASE_URL -f ../scripts/apply-wallet-migration.sql

echo "=== Checking backend logs ==="
pm2 logs advancia-backend --lines 15 --nostream

echo "=== PM2 Status ==="
pm2 list

echo "✅ Frontend fixed and wallet migration applied successfully!"
