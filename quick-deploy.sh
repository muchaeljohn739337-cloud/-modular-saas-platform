#!/bin/bash
# 🚀 Quick Production Deployment Script
# Usage: ./quick-deploy.sh [environment]
# Environment: production (default) or staging

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
ENVIRONMENT=${1:-production}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🚀 Advancia PayLedger - $ENVIRONMENT Deployment${NC}"
echo -e "${YELLOW}Started at: $(date)${NC}"
echo -e "${YELLOW}Project root: $PROJECT_ROOT${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Pre-deployment checks
echo -e "${YELLOW}🔍 Running pre-deployment checks...${NC}"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}❌ PM2 not found. Installing...${NC}"
    npm install -g pm2
fi

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js 18+${NC}"
    exit 1
fi

# Check environment files
if [ ! -f "backend/.env.$ENVIRONMENT" ]; then
    echo -e "${RED}❌ Environment file backend/.env.$ENVIRONMENT not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pre-deployment checks passed${NC}"

# Backup current state
echo -e "${YELLOW}💾 Creating backups...${NC}"
if [ -d "backend/logs" ]; then
    cp -r backend/logs "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Logs backed up${NC}"
fi

if [ -f "ecosystem.config.js" ]; then
    cp ecosystem.config.js "$BACKUP_DIR/"
    echo -e "${GREEN}✅ PM2 config backed up${NC}"
fi

# Stop services gracefully
echo -e "${YELLOW}🛑 Stopping current services...${NC}"
pm2 stop ecosystem.config.js || true
pm2 delete ecosystem.config.js || true

# Build backend
echo -e "${YELLOW}🔨 Building backend...${NC}"
cd backend

# Backup package-lock.json
if [ -f "package-lock.json" ]; then
    cp package-lock.json "$BACKUP_DIR/backend-package-lock.json"
fi

# Install dependencies
npm ci --production=false

# Generate Prisma client and run migrations
npx prisma generate
npx prisma migrate deploy

# Build TypeScript
npm run build

echo -e "${GREEN}✅ Backend built successfully${NC}"

# Build frontend
echo -e "${YELLOW}🔨 Building frontend...${NC}"
cd ../frontend

# Backup package-lock.json
if [ -f "package-lock.json" ]; then
    cp package-lock.json "$BACKUP_DIR/frontend-package-lock.json"
fi

# Install dependencies
npm ci

# Build Next.js
npm run build

echo -e "${GREEN}✅ Frontend built successfully${NC}"

# Return to project root
cd ..

# Start services with PM2
echo -e "${YELLOW}🚀 Starting services with PM2...${NC}"
pm2 start ecosystem.config.js --env $ENVIRONMENT

# Wait for services to start
echo -e "${YELLOW}⏳ Waiting for services to initialize...${NC}"
sleep 10

# Save PM2 configuration
pm2 save

# Health checks
echo -e "${YELLOW}🔍 Running health checks...${NC}"

# Backend health check
MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f -s http://localhost:4000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend health check passed${NC}"
        break
    else
        echo -e "${YELLOW}⏳ Backend not ready, retrying... ($((RETRY_COUNT+1))/$MAX_RETRIES)${NC}"
        sleep 5
        RETRY_COUNT=$((RETRY_COUNT+1))
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Backend health check failed after $MAX_RETRIES attempts${NC}"
    echo -e "${YELLOW}📋 Recent backend logs:${NC}"
    pm2 logs advancia-backend --lines 20 --nostream
    exit 1
fi

# Frontend health check
if curl -f -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend health check passed${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend health check failed, but continuing...${NC}"
    echo -e "${YELLOW}📋 Recent frontend logs:${NC}"
    pm2 logs advancia-frontend --lines 10 --nostream || true
fi

# Post-deployment summary
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "  Environment: $ENVIRONMENT"
echo -e "  Completed at: $(date)"
echo -e "  Backup location: $BACKUP_DIR"

echo -e "${BLUE}📋 Service Status:${NC}"
pm2 list --no-color

echo -e "${BLUE}🔗 Quick Commands:${NC}"
echo -e "  View logs: ${YELLOW}pm2 logs${NC}"
echo -e "  Monitor: ${YELLOW}pm2 monit${NC}"
echo -e "  Restart: ${YELLOW}pm2 restart ecosystem.config.js${NC}"
echo -e "  Stop all: ${YELLOW}pm2 stop ecosystem.config.js${NC}"

echo -e "${BLUE}📁 Log Locations:${NC}"
echo -e "  Backend: backend/logs/"
echo -e "  Frontend: frontend/logs/"
echo -e "  PM2: ~/.pm2/logs/"

echo -e "${GREEN}✅ $ENVIRONMENT deployment completed at $(date)${NC}"

# Optional: Send notification (uncomment and configure)
# curl -X POST -H 'Content-type: application/json' \
#   --data '{"text":"🚀 Advancia deployment to '$ENVIRONMENT' completed successfully"}' \
#   YOUR_SLACK_WEBHOOK_URL

exit 0</content>
<parameter name="filePath">c:\Users\mucha.DESKTOP-H7T9NPM\-modular-saas-platform\-modular-saas-platform\quick-deploy.sh