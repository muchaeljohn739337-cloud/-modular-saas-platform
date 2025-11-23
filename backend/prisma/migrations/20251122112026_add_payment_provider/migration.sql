-- AlterTable
ALTER TABLE "CryptoPayments" ADD COLUMN     "paymentProvider" TEXT DEFAULT 'cryptomus';

-- CreateIndex
CREATE INDEX "CryptoPayments_user_id_idx" ON "CryptoPayments"("user_id");

-- CreateIndex
CREATE INDEX "CryptoPayments_status_idx" ON "CryptoPayments"("status");

-- CreateIndex
CREATE INDEX "CryptoPayments_paymentProvider_idx" ON "CryptoPayments"("paymentProvider");
