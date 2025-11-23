#!/bin/bash
# Quick fix script to setup environment variables and restart services

echo "=========================================="
echo "Fixing Production Environment"
echo "=========================================="

# Create backend .env.production
cat > /var/www/advancia/backend/.env.production << 'EOF'
NODE_ENV=production
PORT=4000
FRONTEND_URL=http://157.245.8.131:3000
ALLOWED_ORIGINS=http://157.245.8.131:3000,http://157.245.8.131

DATABASE_URL=postgresql://your_user:your_password@localhost:5432/advancia_prod

JWT_SECRET=YOUR_JWT_SECRET_HERE
JWT_EXPIRATION=7d
SESSION_SECRET=YOUR_SESSION_SECRET_HERE

STRIPE_SECRET_KEY=sk_test_YOUR_STRIPE_TEST_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_STRIPE_PUBLISHABLE_KEY_HERE

REDIS_URL=redis://localhost:6379
EOF

# Create frontend .env.production
cat > /var/www/advancia/frontend/.env.production << 'EOF'
NEXT_PUBLIC_API_URL=http://157.245.8.131:4000
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_STRIPE_PUBLISHABLE_KEY_HERE
EOF

echo "✓ Environment files created"

# Check if PostgreSQL is running
systemctl start postgresql || true
echo "✓ PostgreSQL started"

# Restart PM2 processes
echo "Restarting services..."
pm2 restart advancia-backend
pm2 restart advancia-frontend

# Wait a moment
sleep 3

# Check status
pm2 status

echo ""
echo "Testing endpoints..."
echo "Backend:"
curl -s http://localhost:4000/health || echo "Backend not responding"

echo ""
echo "Frontend:"
curl -s -I http://localhost:3000 | head -1 || echo "Frontend not responding"

echo ""
echo "=========================================="
echo "Fix complete! Check the output above."
echo "=========================================="
