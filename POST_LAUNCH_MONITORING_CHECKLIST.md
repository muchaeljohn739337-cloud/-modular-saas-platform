<!-- Post-Launch Monitoring Checklist -->

# Post-Launch Monitoring Checklist

Use this checklist immediately after production deployment and during the first 30/60/180 minutes.

## Access & Smoke

1. Homepage reachable (200 < 1s TTFB)
2. `/health` returns `{ status: "ok" }`
3. Critical API endpoints (auth, payments, transactions) respond 2xx
4. `/api/storage/signed-url` works with auth token

## Errors & Stability

1. Sentry events: no sudden spike (> baseline +20%)
2. Uncaught exceptions log count stable
3. Webhook (Stripe) requests accepted (no signature failures)

## Performance Baselines

1. API p95 latency < 400ms
2. DB connections < configured pool limit - 5
3. Queue (RabbitMQ) depth near zero (no stuck jobs)
4. Redis latency < 5ms (if used)

## Resource Utilization

1. CPU < 70% sustained
2. Memory < 75% container limit
3. Disk I/O normal (no sustained high write spikes)
4. Network egress matches expected traffic profile

## Security & Compliance

1. Helmet headers present (X-Frame-Options, X-Content-Type-Options, HSTS)
2. CORS only allows approved origins
3. Rate limit returns 429 under stress test
4. No secrets or PII in logs (spot check recent lines)

## Realtime & Notifications

1. Socket.IO connects and joins user room (`user-<id>`)
2. Admin room receives `sessions:update` broadcasts
3. Test push notification delivered (web-push)
4. Test email (SMTP/Resend) delivered < 15s

## Storage (R2)

1. Upload small object succeeds (`ping.txt`)
2. Signed URL retrieval returns 200
3. Delete object returns success

## Payments

1. Stripe test payment intent: succeeded event processed
2. Webhook log includes verified signature
3. No duplicate processing (idempotency OK)

## Observability Dashboards

1. Error rate panel created (Sentry or logs)
2. Latency panel (p50/p95)
3. Throughput (requests/min)
4. DB pool usage
5. Queue depth / processing rate

## Alerts Configuration

1. Error rate > baseline +50% -> alert
2. p95 latency > 800ms for 5 min -> alert
3. DB connections > pool - 2 -> alert
4. Webhook failures > 3 / 10 min -> alert

## Rollback Readiness

1. Previous stable image/tag available
2. DB schema unchanged post-deploy (no unplanned migrations)
3. Backup snapshot timestamp pre-deploy < 30 min

## Daily Post-Mortem Fields (if incident)

1. Impacted services
2. Root cause hypothesis
3. Mitigations applied
4. Follow-up tickets created

Check items off; escalate if any critical metric deviates beyond thresholds. Keep this file updated as metrics mature.
