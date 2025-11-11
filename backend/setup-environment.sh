# Environment Configuration Setup
# Run this script to set up your production environment

#!/bin/bash

echo "🚀 Setting up Advancia Pay Ledger Environment Configuration"
echo "=========================================================="

# Check if we're in the backend directory
if [ ! -f "package.json" ] || [ ! -d "src" ]; then
    echo "❌ Error: Please run this script from the backend directory"
    exit 1
fi

# Create .env.example if it doesn't exist
if [ ! -f ".env.example" ]; then
    echo "📝 Creating .env.example template..."
    cat > .env.example << 'EOF'
# Environment Configuration
NODE_ENV=development
PORT=5000

# Database
DATABASE_URL="postgresql://username:password@localhost:5432/advancia_pay_ledger"

# Authentication
JWT_SECRET="your-super-secure-jwt-secret-here-minimum-32-characters"
JWT_EXPIRES_IN="24h"

# Encryption
ENCRYPTION_KEY="your-32-character-encryption-key-here"

# Redis (for production rate limiting)
REDIS_URL="redis://localhost:6379"

# Email Service (Resend)
RESEND_API_KEY="your-resend-api-key"
EMAIL_FROM="noreply@yourdomain.com"

# Stripe Payment Processing
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# Crypto Exchange Rates (Optional - fallback to CoinGecko)
EXCHANGE_RATE_API_KEY="your-exchange-rate-api-key"

# Admin Configuration
ADMIN_EMAIL="admin@yourdomain.com"
ADMIN_PASSWORD="change-this-immediately"

# CORS Configuration
FRONTEND_URL="http://localhost:3000"
ALLOWED_ORIGINS="http://localhost:3000,https://yourdomain.com"

# Security
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=300

# Logging
LOG_LEVEL="info"
LOG_FILE="logs/app.log"

# Monitoring (Optional)
SENTRY_DSN="your-sentry-dsn"
EOF
    echo "✅ Created .env.example"
fi

# Create .env.local for development
if [ ! -f ".env.local" ]; then
    echo "🔧 Creating .env.local for development..."
    cat > .env.local << 'EOF'
# Development Environment Configuration
NODE_ENV=development
PORT=5000

# Database (Local PostgreSQL)
DATABASE_URL="postgresql://postgres:password@localhost:5432/advancia_pay_ledger_dev"

# Authentication (Development keys - CHANGE IN PRODUCTION)
JWT_SECRET="dev-jwt-secret-change-this-in-production-32-chars-min"
JWT_EXPIRES_IN="24h"

# Encryption (Development key - CHANGE IN PRODUCTION)
ENCRYPTION_KEY="dev-encryption-key-32-characters-long"

# Redis (Local Redis instance)
REDIS_URL="redis://localhost:6379"

# Email Service (Development - use Ethereal or similar)
RESEND_API_KEY="dev-api-key"
EMAIL_FROM="dev@advancia.com"

# Stripe (Test keys)
STRIPE_SECRET_KEY="sk_test_your_test_key_here"
STRIPE_PUBLISHABLE_KEY="pk_test_your_publishable_key_here"
STRIPE_WEBHOOK_SECRET="whsec_test_webhook_secret"

# Admin Configuration
ADMIN_EMAIL="admin@advancia.com"
ADMIN_PASSWORD="Admin123!"

# CORS Configuration
FRONTEND_URL="http://localhost:3000"
ALLOWED_ORIGINS="http://localhost:3000,http://localhost:3001"

# Security
BCRYPT_ROUNDS=10
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=1000

# Logging
LOG_LEVEL="debug"
LOG_FILE="logs/dev.log"
EOF
    echo "✅ Created .env.local"
fi

# Create .env.production template
if [ ! -f ".env.production" ]; then
    echo "🏭 Creating .env.production template..."
    cat > .env.production << 'EOF'
# Production Environment Configuration
NODE_ENV=production
PORT=5000

# Database (Production PostgreSQL)
DATABASE_URL="postgresql://username:password@production-host:5432/advancia_pay_ledger_prod"

# Authentication (PRODUCTION SECRETS - KEEP SECURE)
JWT_SECRET="prod-jwt-secret-minimum-32-characters-high-entropy"
JWT_EXPIRES_IN="12h"

# Encryption (PRODUCTION KEY - KEEP SECURE)
ENCRYPTION_KEY="prod-encryption-key-32-characters-high-entropy"

# Redis (Production Redis)
REDIS_URL="redis://production-redis-host:6379"

# Email Service (Production Resend)
RESEND_API_KEY="prod-resend-api-key"
EMAIL_FROM="noreply@yourdomain.com"

# Stripe (Production keys)
STRIPE_SECRET_KEY="sk_live_your_live_secret_key"
STRIPE_PUBLISHABLE_KEY="pk_live_your_live_publishable_key"
STRIPE_WEBHOOK_SECRET="whsec_live_webhook_secret"

# Admin Configuration
ADMIN_EMAIL="admin@yourdomain.com"
ADMIN_PASSWORD="CHANGE_THIS_IMMEDIATELY_AFTER_FIRST_LOGIN"

# CORS Configuration
FRONTEND_URL="https://yourdomain.com"
ALLOWED_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"

# Security (Stricter in production)
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=300

# Logging
LOG_LEVEL="warn"
LOG_FILE="logs/prod.log"

# Monitoring
SENTRY_DSN="https://your-sentry-dsn@sentry.io/project-id"
EOF
    echo "✅ Created .env.production"
fi

# Create environment validation script
if [ ! -f "scripts/validate-env.js" ]; then
    echo "🔍 Creating environment validation script..."
    mkdir -p scripts
    cat > scripts/validate-env.js << 'EOF'
#!/usr/bin/env node

/**
 * Environment Validation Script
 * Validates that all required environment variables are set
 */

const requiredVars = [
    'NODE_ENV',
    'DATABASE_URL',
    'JWT_SECRET',
    'ENCRYPTION_KEY',
    'RESEND_API_KEY',
    'EMAIL_FROM',
    'STRIPE_SECRET_KEY',
    'STRIPE_PUBLISHABLE_KEY'
];

const recommendedVars = [
    'REDIS_URL',
    'JWT_EXPIRES_IN',
    'BCRYPT_ROUNDS',
    'RATE_LIMIT_MAX_REQUESTS'
];

console.log('🔍 Validating Environment Configuration\n');

let missingRequired = [];
let missingRecommended = [];

requiredVars.forEach(varName => {
    if (!process.env[varName]) {
        missingRequired.push(varName);
    }
});

recommendedVars.forEach(varName => {
    if (!process.env[varName]) {
        missingRecommended.push(varName);
    }
});

if (missingRequired.length > 0) {
    console.log('❌ Missing Required Environment Variables:');
    missingRequired.forEach(varName => {
        console.log(`   - ${varName}`);
    });
    console.log('\n💡 Set these variables in your .env file');
    process.exit(1);
}

if (missingRecommended.length > 0) {
    console.log('⚠️  Missing Recommended Environment Variables:');
    missingRecommended.forEach(varName => {
        console.log(`   - ${varName}`);
    });
    console.log('\n💡 Consider setting these for optimal performance');
}

console.log('✅ Environment validation passed!');

// Additional validations
const issues = [];

// Check JWT secret length
if (process.env.JWT_SECRET && process.env.JWT_SECRET.length < 32) {
    issues.push('JWT_SECRET should be at least 32 characters long');
}

// Check encryption key length
if (process.env.ENCRYPTION_KEY && process.env.ENCRYPTION_KEY.length !== 32) {
    issues.push('ENCRYPTION_KEY must be exactly 32 characters long');
}

// Check database URL format
if (process.env.DATABASE_URL && !process.env.DATABASE_URL.startsWith('postgresql://')) {
    issues.push('DATABASE_URL should start with postgresql://');
}

if (issues.length > 0) {
    console.log('\n⚠️  Configuration Issues:');
    issues.forEach(issue => {
        console.log(`   - ${issue}`);
    });
} else {
    console.log('✅ All configurations look good!');
}

console.log('\n🎯 Ready to start the application!');
EOF
    chmod +x scripts/validate-env.js
    echo "✅ Created scripts/validate-env.js"
fi

# Create logs directory
if [ ! -d "logs" ]; then
    echo "📁 Creating logs directory..."
    mkdir -p logs
    echo "✅ Created logs directory"
fi

echo ""
echo "🎉 Environment setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Copy .env.example to .env and fill in your values"
echo "2. Run: node scripts/validate-env.js"
echo "3. Start the application: npm run dev"
echo ""
echo "🔐 Security Notes:"
echo "- Never commit .env files to version control"
echo "- Use strong, unique secrets in production"
echo "- Rotate encryption keys regularly"
echo "- Keep admin passwords secure"
