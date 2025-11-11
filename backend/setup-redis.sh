#!/bin/bash

# Redis Setup Script for Advancia Pay Ledger
# This script helps set up Redis for rate limiting

echo "🔴 Setting up Redis for Rate Limiting"
echo "====================================="

# Check if Redis is installed
if command -v redis-server &> /dev/null; then
    echo "✅ Redis is installed"
else
    echo "❌ Redis is not installed"
    echo ""
    echo "📦 Installing Redis..."

    # Install Redis based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y redis-server
        elif command -v yum &> /dev/null; then
            sudo yum install -y redis
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y redis
        else
            echo "❌ Unsupported Linux distribution. Please install Redis manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install redis
        else
            echo "❌ Homebrew not found. Please install Redis manually or install Homebrew first."
            exit 1
        fi
    else
        echo "❌ Unsupported OS. Please install Redis manually."
        exit 1
    fi

    echo "✅ Redis installed successfully"
fi

# Start Redis service
echo ""
echo "🚀 Starting Redis service..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo systemctl start redis-server 2>/dev/null || sudo service redis-server start 2>/dev/null || redis-server --daemonize yes
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew services start redis 2>/dev/null || redis-server --daemonize yes
fi

# Wait a moment for Redis to start
sleep 2

# Test Redis connection
echo ""
echo "🧪 Testing Redis connection..."
if redis-cli ping &> /dev/null; then
    echo "✅ Redis is running and responding to ping"
else
    echo "❌ Redis connection failed"
    echo "💡 Try starting Redis manually: redis-server"
    exit 1
fi

# Configure Redis for production use
echo ""
echo "⚙️  Configuring Redis for production use..."

# Create Redis configuration for production
if [ ! -f "redis.conf" ]; then
    cat > redis.conf << 'EOF'
# Redis configuration for Advancia Pay Ledger
# Production-ready settings

# Network
bind 127.0.0.1
port 6379
timeout 0
tcp-keepalive 300

# General
daemonize yes
supervised no
loglevel notice
logfile "logs/redis.log"

# Snapshotting
save 900 1
save 300 10
save 60 10000

# Security
# requirepass your-redis-password-here

# Memory management
maxmemory 256mb
maxmemory-policy allkeys-lru

# Append only file
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec

# Disable dangerous commands in production
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command SHUTDOWN SHUTDOWN_REDIS
EOF
    echo "✅ Created redis.conf"
fi

echo ""
echo "🎉 Redis setup complete!"
echo ""
echo "📋 Redis Configuration:"
echo "   - Local Redis: redis://localhost:6379"
echo "   - Config file: redis.conf"
echo "   - Logs: logs/redis.log"
echo ""
echo "🔧 For production, consider:"
echo "   - Using Redis Cloud, Upstash, or AWS ElastiCache"
echo "   - Setting a password with 'requirepass' in redis.conf"
echo "   - Configuring persistence and backups"
echo "   - Setting up Redis cluster for high availability"
echo ""
echo "🧪 Test rate limiting:"
echo "   npm run test:security"
