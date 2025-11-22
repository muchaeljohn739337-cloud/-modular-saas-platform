-- CreateIndex
CREATE INDEX "crypto_withdrawals_userId_status_idx" ON "crypto_withdrawals"("userId", "status");

-- CreateIndex
CREATE INDEX "crypto_withdrawals_status_requestedAt_idx" ON "crypto_withdrawals"("status", "requestedAt" DESC);

-- CreateIndex
CREATE INDEX "transactions_userId_createdAt_idx" ON "transactions"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "transactions_status_type_idx" ON "transactions"("status", "type");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE INDEX "users_active_idx" ON "users"("active");

-- CreateIndex
CREATE INDEX "users_emailVerified_idx" ON "users"("emailVerified");
