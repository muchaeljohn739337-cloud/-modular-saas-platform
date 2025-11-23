// Generate Production Secrets Script
// Run: node scripts/generate-secrets.js

const crypto = require("crypto");

console.log("\n========================================");
console.log("PRODUCTION SECRETS GENERATOR");
console.log("========================================\n");

console.log("⚠️  WARNING: Copy these to a password manager immediately!");
console.log("⚠️  NEVER commit these to git or share via insecure channels!\n");

// Generate JWT secrets (64 chars)
const jwtSecret = crypto.randomBytes(32).toString("hex");
const jwtRefreshSecret = crypto.randomBytes(32).toString("hex");
const sessionSecret = crypto.randomBytes(32).toString("hex");

// Generate OTP secret (32 chars)
const otpSecret = crypto.randomBytes(16).toString("hex");

// Generate wallet encryption key (32 bytes for AES-256)
const walletEncryptionKey = crypto.randomBytes(32).toString("hex");

// Generate NextAuth secret
const nextAuthSecret = crypto.randomBytes(32).toString("hex");

console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
console.log("BACKEND SECRETS");
console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

console.log("# Authentication Secrets");
console.log(`JWT_SECRET=${jwtSecret}`);
console.log(`JWT_REFRESH_SECRET=${jwtRefreshSecret}`);
console.log(`SESSION_SECRET=${sessionSecret}`);
console.log(`OTP_SECRET=${otpSecret}\n`);

console.log("# Wallet Security (CRITICAL!)");
console.log(`WALLET_ENCRYPTION_KEY=${walletEncryptionKey}`);
console.log("WALLET_MASTER_SEED=<USE_BIP39_MNEMONIC_24_WORDS>\n");

console.log("# Generate BIP39 mnemonic at: https://iancoleman.io/bip39/");
console.log("# Select 24 words, copy the mnemonic phrase\n");

console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
console.log("FRONTEND SECRETS");
console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

console.log(`NEXTAUTH_SECRET=${nextAuthSecret}\n`);

console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
console.log("MANUAL SETUP REQUIRED");
console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

console.log("1. STRIPE (https://dashboard.stripe.com)");
console.log("   - Get LIVE keys: Developers → API keys");
console.log("   - Create webhook: Developers → Webhooks");
console.log("   - Endpoint: https://api.your-domain.com/api/payments/webhook");
console.log("   - Events: payment_intent.succeeded, payment_intent.failed\n");

console.log("2. GMAIL APP PASSWORD (https://myaccount.google.com/security)");
console.log("   - Enable 2FA first");
console.log("   - Go to Security → 2-Step Verification → App passwords");
console.log('   - Generate password for "Mail"\n');

console.log("3. CRYPTO ADMIN WALLETS");
console.log("   - Generate secure Bitcoin wallet (use hardware wallet)");
console.log("   - Generate secure Ethereum wallet (use hardware wallet)");
console.log("   - NEVER use exchange wallets for production!\n");

console.log("4. SENTRY (https://sentry.io)");
console.log("   - Create new project");
console.log("   - Copy DSN from Settings → Client Keys\n");

console.log("5. AWS S3 (for backups)");
console.log("   - Create IAM user with S3 access");
console.log("   - Generate access key and secret\n");

console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
console.log("NEXT STEPS");
console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

console.log("1. Copy secrets to password manager");
console.log("2. Fill in .env.production.template");
console.log("3. Run: npx ts-node scripts/verify-env.ts");
console.log("4. Follow PRE_DEPLOYMENT_CHECKLIST.md\n");

console.log("✅ Secrets generated successfully!\n");
