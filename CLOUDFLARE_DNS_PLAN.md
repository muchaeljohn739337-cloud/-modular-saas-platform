# Cloudflare DNS Plan (Zero-Downtime)

## Targets

- Frontend (Vercel): apex/root `your-domain.com` and `www` → Vercel
- Backend API (Render): `api.your-domain.com` → Render custom domain

## Records

- Apex/root: follow Vercel DNS wizard (CNAME flattening to Vercel)
- `CNAME` `www` → your Vercel project domain
- `CNAME` `api` → your Render service custom domain

## SSL & Security

- SSL/TLS: Full (strict)
- HSTS: enable with preload after validation
- WAF: enable core rules; add rate limiting to `/api/auth/*` and `/api/payments/*`

## Cutover Steps

- Validate apps on provider subdomains (Vercel + Render)
- Set DNS TTL to 120s (low) for apex/www/api
- Point apex/www to Vercel and `api` to Render
- Verify: `/api/health`, end-to-end flows, Stripe webhook test event
- Raise TTL to 30m after stability
