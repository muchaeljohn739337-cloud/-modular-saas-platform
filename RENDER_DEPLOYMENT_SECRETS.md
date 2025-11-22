# 🔐 Render Deployment - Environment Variables

**⚠️ SECURITY WARNING: Delete this file after copying secrets to Render!**

## Backend Service: srv-d4f29vadbo4c738b4dsg

Go to: [Render Dashboard - Backend Service](https://dashboard.render.com/web/srv-d4f29vadbo4c738b4dsg/env-vars)

Add these environment variables:

### 🔑 Required Secrets (Generated)

```bash
JWT_SECRET=26373148a4dc57ca185e3c28d5c0f5e62aaf65de42e5ff112671ea6ada8a82a4862d96b70378d7e89f3026df8ee8feb6f98f30acc385fc77ce1149ac9b64eedb

SESSION_SECRET=9c937f2cffe448795b67b22dda7e4633a20afeb921f76c7e318f334e84e1d469e8f2a5fa0fc6656508f3853a3876db82013bb735bffae029eeabfaa8cb3a0014

JWT_SECRET_ENCRYPTED=451b119d54937f2837be04577ea89582a41c35f4cd442acac8f5a0d39b56755706c87e94052bb82405d69fa47c5e723d3e4f77b7b70ca4fe3d53b570b7b9f059

JWT_ENCRYPTION_KEY=27b02842f7342e98d588d97201050f0284e21e7cad8b9d71bff2093d65261559

JWT_ENCRYPTION_IV=5b4505dafc9542bca397f46a1eed201a
```

### 📊 Database (Already in render.yaml)

```bash
DATABASE_URL=postgresql://db_adnan_postrl_user:Gd1XFfDxFVsM5MltemAhFE3zPNcRh5hg@dpg-d4f112trnu6s73doipjg-a.oregon-postgres.render.com/db_adnan_postrl
```

### 🌐 Frontend URLs (Already in render.yaml)

```bash
FRONTEND_URL=https://advanciapayledger.com
ALLOWED_ORIGINS=https://advanciapayledger.com,https://www.advanciapayledger.com
NODE_ENV=production
PORT=4000
```

### 💳 Payment Keys (Add if you have them)

```bash
# Stripe
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_secret_here

# Cryptomus
CRYPTOMUS_API_KEY=your_api_key_here
CRYPTOMUS_MERCHANT_ID=your_merchant_id_here
```

### 📧 Email Configuration (Optional)

```bash
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-gmail-app-password
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

# Resend API
RESEND_API_KEY=re_your_resend_api_key

# SendGrid
SENDGRID_API_KEY=SG.your_sendgrid_api_key
```

### 🔔 Push Notifications (Optional)

```bash
VAPID_PUBLIC_KEY=your_public_key
VAPID_PRIVATE_KEY=your_private_key
VAPID_SUBJECT=mailto:support@advanciapayledger.com
```

### 📊 Monitoring (Optional)

```bash
SENTRY_DSN=your_sentry_dsn_here
```

---

## 🚀 Deployment Steps

### 1. Add Secrets to Render Dashboard

1. Go to: [Render Dashboard - Backend Service](https://dashboard.render.com/web/srv-d4f29vadbo4c738b4dsg)
2. Click **Environment** tab
3. Add each secret above
4. Click **Save Changes**

### 2. Push to GitHub (Triggers Auto-Deploy)

```powershell
git add .
git commit -m "chore: configure backend for Render deployment"
git push origin preview-clean
```

### 3. Monitor Deployment

Watch logs: [Render Dashboard - Logs](https://dashboard.render.com/web/srv-d4f29vadbo4c738b4dsg/logs)

### 4. Get Backend URL

After deployment completes, copy the URL (e.g., `advancia-backend-xxxx.onrender.com`)

### 5. Update Cloudflare DNS

In Cloudflare dashboard:

- Change `api.advanciapayledger.com` CNAME target to your Render URL
- Keep Proxy enabled (orange cloud ✅)

### 6. Test Deployment

```powershell
curl https://api.advanciapayledger.com/api/health
```

---

## 🔒 Security Checklist

- [ ] All secrets added to Render dashboard
- [ ] render.yaml pushed to GitHub
- [ ] Deployment successful (check logs)
- [ ] Health endpoint returns 200 OK
- [ ] Cloudflare DNS updated
- [ ] **DELETE THIS FILE after deployment!**

---

## 📝 Notes

- Render free tier: First deploy takes ~5 minutes
- Auto-deploys on every push to `preview-clean` branch
- Health check: `/api/health` (configured in render.yaml)
- Build command: `npm ci && npx prisma generate && npx prisma migrate deploy && npm run build`
- Start command: `npm start`

**⚠️ IMPORTANT: Delete this file after copying secrets to Render Dashboard!**
