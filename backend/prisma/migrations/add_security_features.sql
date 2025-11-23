-- Add Security Features Migration
-- This migration adds BreachAlert, IPRotationLog, and SecuritySettings models

-- Create breach_alerts table
CREATE TABLE IF NOT EXISTS "breach_alerts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "breachName" TEXT NOT NULL,
    "breachDate" TIMESTAMP,
    "dataClasses" TEXT[] NOT NULL DEFAULT '{}',
    "pwnCount" INTEGER NOT NULL DEFAULT 0,
    "notified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for breach_alerts
CREATE INDEX IF NOT EXISTS "breach_alerts_userId_idx" ON "breach_alerts"("userId");
CREATE INDEX IF NOT EXISTS "breach_alerts_email_idx" ON "breach_alerts"("email");

-- Create ip_rotation_logs table
CREATE TABLE IF NOT EXISTS "ip_rotation_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "originalIP" TEXT NOT NULL,
    "maskedIP" TEXT NOT NULL,
    "targetCountry" TEXT NOT NULL,
    "city" TEXT,
    "vpnActive" BOOLEAN NOT NULL DEFAULT false,
    "proxyActive" BOOLEAN NOT NULL DEFAULT true,
    "locationMasked" BOOLEAN NOT NULL DEFAULT false,
    "provider" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for ip_rotation_logs
CREATE INDEX IF NOT EXISTS "ip_rotation_logs_userId_idx" ON "ip_rotation_logs"("userId");
CREATE INDEX IF NOT EXISTS "ip_rotation_logs_createdAt_idx" ON "ip_rotation_logs"("createdAt");

-- Create security_settings table
CREATE TABLE IF NOT EXISTS "security_settings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL UNIQUE,
    "breachMonitoringActive" BOOLEAN NOT NULL DEFAULT false,
    "ipProtectionActive" BOOLEAN NOT NULL DEFAULT false,
    "vpnEnabled" BOOLEAN NOT NULL DEFAULT false,
    "proxyEnabled" BOOLEAN NOT NULL DEFAULT false,
    "locationMaskingEnabled" BOOLEAN NOT NULL DEFAULT false,
    "preferredCountry" TEXT,
    "autoRotateIP" BOOLEAN NOT NULL DEFAULT false,
    "rotationIntervalHours" INTEGER NOT NULL DEFAULT 24,
    "emailAlerts" BOOLEAN NOT NULL DEFAULT true,
    "pushNotifications" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create unique index for security_settings
CREATE UNIQUE INDEX IF NOT EXISTS "security_settings_userId_idx" ON "security_settings"("userId");

-- Add subscription fields to users table (if not exists)
-- Note: Run these separately if the columns don't exist
-- ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "subscriptionTier" TEXT NOT NULL DEFAULT 'FREE';
-- ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "subscriptionStatus" TEXT NOT NULL DEFAULT 'active';
-- ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "trialEndsAt" TIMESTAMP;
-- ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "subscriptionEndsAt" TIMESTAMP;

-- Comments for documentation
COMMENT ON TABLE "breach_alerts" IS 'Stores data breach monitoring alerts for users';
COMMENT ON TABLE "ip_rotation_logs" IS 'Logs IP rotation and masking activity';
COMMENT ON TABLE "security_settings" IS 'User security preferences and settings';
