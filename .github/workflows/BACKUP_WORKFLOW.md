# Backup Database to Cloudflare R2 – Ops Guide

This workflow creates a timestamped PostgreSQL backup and uploads it to Cloudflare R2 using the S3-compatible endpoint, then (optionally) pings your API health URL and posts Slack notifications.

## Triggers

- Manual: GitHub → Actions → “Backup Database to Cloudflare R2” → Run workflow
- Scheduled: Daily at 02:17 UTC (see `schedule.cron`)

## Required GitHub Secrets

- `DATABASE_URL`: Postgres connection string (external URL). If using Render Postgres, ensure SSL is enabled (e.g., `sslmode=require`).
- `R2_BUCKET`: Cloudflare R2 bucket name (e.g., `advancia-backups`).
- Either:
  - `R2_ACCOUNT_ID`: Cloudflare account ID (workflow derives endpoint as `https://<account>.r2.cloudflarestorage.com`), or
  - `R2_ENDPOINT`: Full endpoint URL (e.g., `https://<account>.r2.cloudflarestorage.com`).
- `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`: R2 API token credentials with Object Read/Write permission scoped to the backup bucket.

## Optional Secrets

- `HEALTH_URL`: API health endpoint to check after upload (e.g., `https://api.your-domain.com/api/health`).
- `SLACK_WEBHOOK_URL`: Incoming webhook to receive success/failure notifications.

## What it does

1. Installs `postgresql-client` and runs `pg_dump` to produce `db-backup-<UTC timestamp>.dump` (custom format).
2. Uses AWS CLI with `--endpoint-url` to upload to `s3://<R2_BUCKET>/backups/backend/`.
3. Verifies the object exists via `aws s3 ls` (HEAD).
4. Optionally checks your API health and posts to Slack.

## Verify a run

- R2 object key: `backups/backend/db-backup-YYYYMMDDTHHMMSSZ.dump`
- Actions logs show upload/verify steps.
- If `HEALTH_URL` is set, logs will show 12 attempts (up to ~60s) with success/failure.
- If `SLACK_WEBHOOK_URL` is set, you’ll receive a status message.

## Troubleshooting

- Missing endpoint: Provide `R2_ENDPOINT` or `R2_ACCOUNT_ID`.
- Access denied: Ensure the R2 token has Object Read/Write scoped to the bucket.
- SSL/connection errors: Confirm `DATABASE_URL` is reachable from GitHub runners and includes SSL options.
- Large DB: Consider enabling compression at the bucket or keeping `pg_dump` custom format (already compressed).

## Notes

- No database credentials or tokens are committed; everything is injected via GitHub Secrets.
- The bucket path keeps backups organized by service: `backups/backend/`.
- Rotate R2 tokens periodically and audit bucket access.
