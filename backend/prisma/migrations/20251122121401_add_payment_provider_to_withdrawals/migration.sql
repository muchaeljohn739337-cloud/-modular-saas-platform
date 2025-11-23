-- AlterTable
ALTER TABLE "crypto_withdrawals" ADD COLUMN     "paymentProvider" TEXT DEFAULT 'cryptomus';

-- CreateIndex
CREATE INDEX "crypto_withdrawals_paymentProvider_idx" ON "crypto_withdrawals"("paymentProvider");
