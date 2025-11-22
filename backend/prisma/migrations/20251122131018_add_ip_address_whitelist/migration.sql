-- AlterTable
ALTER TABLE "users" ADD COLUMN     "whitelistedIPs" TEXT[];

-- CreateTable
CREATE TABLE "whitelisted_addresses" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "currency" TEXT NOT NULL,
    "label" TEXT,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "whitelisted_addresses_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "whitelisted_addresses_userId_idx" ON "whitelisted_addresses"("userId");

-- CreateIndex
CREATE INDEX "whitelisted_addresses_verified_idx" ON "whitelisted_addresses"("verified");

-- CreateIndex
CREATE UNIQUE INDEX "whitelisted_addresses_userId_address_currency_key" ON "whitelisted_addresses"("userId", "address", "currency");

-- AddForeignKey
ALTER TABLE "whitelisted_addresses" ADD CONSTRAINT "whitelisted_addresses_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
