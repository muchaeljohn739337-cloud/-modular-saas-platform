#!/bin/bash
# Complete Production Fix Script
# Run this ON THE DROPLET: bash /tmp/fix-production-complete.sh

set -e

echo "========================================="
echo "Starting Production Fix"
echo "========================================="

# Kill PM2 to release file locks
echo "Step 1: Stopping PM2..."
pm2 kill || true
sleep 2

# Clean ALL node_modules (root + frontend)
echo "Step 2: Cleaning corrupted node_modules..."
cd /var/www/advancia
rm -rf node_modules frontend/node_modules frontend/.next frontend/package-lock.json package-lock.json
echo "✓ Cleaned successfully"

# Reinstall frontend
echo "Step 3: Reinstalling frontend dependencies..."
cd /var/www/advancia/frontend
npm install --legacy-peer-deps
echo "✓ Dependencies installed"

echo "Step 4: Building frontend..."
npm run build
echo "✓ Frontend built successfully"

# Apply wallet migration
echo "Step 5: Applying wallet migration to database..."
cd /var/www/advancia/backend
psql $DATABASE_URL -f ../scripts/apply-wallet-migration.sql
echo "✓ Migration applied successfully"

# Restart services
echo "Step 6: Restarting services with PM2..."
cd /var/www/advancia
pm2 start ecosystem.config.js
pm2 save
echo "✓ Services restarted"

# Show status
echo ""
echo "========================================="
echo "Final Status:"
echo "========================================="
pm2 list
pm2 logs --lines 5 --nostream

echo ""
echo "✅ Production fix completed successfully!"
echo ""
echo "Next steps:"
echo "1. Test frontend: curl http://localhost:3000"
echo "2. Test backend: curl http://localhost:4000/health"
echo "3. Verify wallets: Check database tables crypto_wallet_keys and crypto_wallet_history"
