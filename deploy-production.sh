#!/bin/bash

# Production Deployment Script for Advancia Pay Ledger
# Complete production setup and deployment

set -e  # Exit on any error

echo "🚀 Advancia Pay Ledger - Production Deployment"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root (for system services)
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Check Node.js version
print_status "Checking Node.js version..."
NODE_VERSION=$(node --version | sed 's/v//')
REQUIRED_NODE="18.0.0"
if ! [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_NODE" ]; then
    print_error "Node.js $REQUIRED_NODE or higher required. Current: $NODE_VERSION"
    exit 1
fi
print_success "Node.js version: $NODE_VERSION"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    print_status "Installing PM2..."
    npm install -g pm2
    print_success "PM2 installed"
fi

# Setup environment
print_status "Setting up environment..."
if [ ! -f ".env.production" ]; then
    print_warning "Production environment file not found. Creating template..."
    cat > .env.production << 'EOF'
# Production Environment Configuration
NODE_ENV=production
PORT=5000

# Database
DATABASE_URL="postgresql://username:password@localhost:5432/advancia_prod"

# JWT
JWT_SECRET="your-super-secure-jwt-secret-here-64-chars-minimum"
JWT_REFRESH_SECRET="your-super-secure-refresh-secret-here-64-chars-minimum"

# Encryption
ENCRYPTION_KEY="your-32-character-encryption-key-here-exactly-32-chars"

# Redis
REDIS_URL="redis://localhost:6379"

# Stripe
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# Email
RESEND_API_KEY="re_..."
ADMIN_EMAIL="admin@yourdomain.com"
ALERT_EMAIL="alerts@yourdomain.com"

# Security
CORS_ORIGIN="https://yourdomain.com"
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Monitoring
HEALTH_CHECK_URL="https://yourdomain.com/health"
LOG_FILE="logs/app.log"
EOF
    print_warning "Please edit .env.production with your actual values before proceeding"
    read -p "Press Enter after configuring .env.production..."
fi

# Copy production environment
cp .env.production .env
print_success "Environment configured"

# Setup Redis
print_status "Setting up Redis..."
if [ ! -f "setup-redis.sh" ]; then
    print_error "Redis setup script not found"
    exit 1
fi

chmod +x setup-redis.sh
./setup-redis.sh

# Setup monitoring
print_status "Setting up monitoring..."
if [ ! -f "setup-monitoring.sh" ]; then
    print_error "Monitoring setup script not found"
    exit 1
fi

chmod +x setup-monitoring.sh
./setup-monitoring.sh

# Install dependencies
print_status "Installing dependencies..."
npm ci --production=false
print_success "Dependencies installed"

# Build application
print_status "Building application..."
npm run build
print_success "Application built"

# Create logs directory
print_status "Setting up logging..."
mkdir -p logs
print_success "Logs directory created"

# Run database migrations
print_status "Running database migrations..."
npx prisma migrate deploy
print_success "Database migrations completed"

# Seed database (optional)
read -p "Do you want to seed the database with initial data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Seeding database..."
    npx prisma db seed
    print_success "Database seeded"
fi

# Stop existing PM2 processes
print_status "Stopping existing processes..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Start application with monitoring
print_status "Starting application with monitoring..."
pm2 start ecosystem-monitoring.json
print_success "Application and monitoring started"

# Setup PM2 startup script
print_status "Setting up PM2 auto-startup..."
pm2 startup
pm2 save
print_success "PM2 auto-startup configured"

# Setup log rotation
print_status "Setting up log rotation..."
if command -v logrotate &> /dev/null; then
    sudo tee /etc/logrotate.d/advancia-pay-ledger > /dev/null << EOF
/var/www/advancia-pay-ledger/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        pm2 reloadLogs
    endscript
}
EOF
    print_success "Log rotation configured"
else
    print_warning "logrotate not available. Consider installing for log management"
fi

# Setup firewall (basic)
print_status "Configuring firewall..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    print_success "Firewall configured"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=22/tcp
    sudo firewall-cmd --permanent --add-port=80/tcp
    sudo firewall-cmd --permanent --add-port=443/tcp
    sudo firewall-cmd --reload
    print_success "Firewall configured"
else
    print_warning "No supported firewall found. Configure manually"
fi

# Health check
print_status "Performing final health check..."
sleep 5

if curl -f -s http://localhost:5000/health > /dev/null; then
    print_success "Application is healthy!"
else
    print_error "Application health check failed"
    exit 1
fi

# Display status
print_success "🎉 Production deployment completed successfully!"
echo ""
echo "📊 Application Status:"
pm2 status
echo ""
echo "📋 Useful Commands:"
echo "   View logs: pm2 logs"
echo "   Monitor: pm2 monit"
echo "   Restart: pm2 restart all"
echo "   Stop: pm2 stop all"
echo ""
echo "🌐 Application should be available at:"
echo "   Health Check: http://localhost:5000/health"
echo "   API: http://localhost:5000/api"
echo ""
echo "🔧 Next Steps:"
echo "   1. Configure reverse proxy (nginx/apache)"
echo "   2. Setup SSL certificate"
echo "   3. Configure domain DNS"
echo "   4. Setup backup strategy"
echo "   5. Configure monitoring alerts"
echo ""
print_warning "Remember to:"
print_warning "  - Update .env.production with real secrets"
print_warning "  - Configure domain and SSL"
print_warning "  - Setup automated backups"
print_warning "  - Monitor logs and alerts"