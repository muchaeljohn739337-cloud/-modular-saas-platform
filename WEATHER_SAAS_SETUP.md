# 🚀 Weather SaaS Setup Guide

## Quick Start (5 minutes)

### 1. Run Database Migration

```bash
cd backend
npx prisma migrate dev --name add_weather_saas_features
npx prisma generate
```

This adds:

- `SubscriptionTier` enum (FREE, PRO, BUSINESS, ENTERPRISE)
- `WeatherApiUsage` tracking table
- `WeatherAlert` for premium alerts
- User subscription fields

### 2. Set OpenWeatherMap API Key

```bash
# Get FREE API key from https://openweathermap.org/api
# Add to backend/.env
echo "OPENWEATHERMAP_API_KEY=your_api_key_here" >> backend/.env
```

### 3. Initialize User Subscription Defaults

```sql
-- Run this SQL to set default subscription tier for existing users
UPDATE users SET
  "subscriptionTier" = 'FREE',
  "weatherApiCallsLimit" = 50,
  "weatherApiCallsUsed" = 0,
  "weatherApiCallsResetAt" = NOW() + INTERVAL '1 day'
WHERE "subscriptionTier" IS NULL;
```

Or use Prisma Studio:

```bash
cd backend
npx prisma studio
```

### 4. Start Backend & Frontend

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### 5. Test the API

```bash
# Get pricing info (public)
curl http://localhost:4000/api/weather/pricing

# Get current weather (requires auth token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:4000/api/weather?city=London"

# Check usage stats
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/api/weather/usage
```

---

## 🎨 Frontend Components

### Option 1: Use New SaaS Component (Recommended)

```tsx
// frontend/src/app/weather/page.tsx
import WeatherSaaSDashboard from "@/components/WeatherSaaSDashboard";

export default function WeatherPage() {
  return <WeatherSaaSDashboard />;
}
```

### Option 2: Keep Basic Component

```tsx
// Use the original WeatherDashboard.tsx
import WeatherDashboard from "@/components/WeatherDashboard";
```

**Endpoints:**

- `/api/weather-basic` - Original basic weather (no auth)
- `/api/weather` - New SaaS weather (auth + tiers)

---

## 📊 API Endpoints

### Public Endpoints

```typescript
GET / api / weather / pricing;
// Returns subscription tiers and pricing
```

### Authenticated Endpoints

```typescript
GET /api/weather/usage
// Get user's API usage statistics

GET /api/weather?city=London&units=metric
// Current weather (all tiers)
// Rate limited based on subscription

GET /api/weather/forecast?city=London&units=metric
// 5-day forecast (Pro tier+)

POST /api/weather/batch
// Batch city lookups (Business tier+)
Body: { cities: ["London", "Paris", "Tokyo"], units: "metric" }

POST /api/weather/alerts
// Create weather alert (Pro tier+)
Body: {
  city: "London",
  alertType: "temperature",
  condition: "{\"temp\": {\"above\": 30}}",
  notificationMethod: "email"
}

GET /api/weather/alerts
// List user's alerts

DELETE /api/weather/alerts/:id
// Delete alert
```

---

## 🔧 Configuration

### Subscription Tier Limits

Edit `backend/src/routes/weatherSaas.ts`:

```typescript
const TIER_LIMITS = {
  FREE: { dailyLimit: 50, features: ["current"], price: 0 },
  PRO: {
    dailyLimit: 1000,
    features: ["current", "forecast", "alerts"],
    price: 9.99,
  },
  BUSINESS: {
    dailyLimit: 10000,
    features: ["current", "forecast", "alerts", "batch"],
    price: 49.99,
  },
  ENTERPRISE: { dailyLimit: -1, features: ["*"], price: 299.99 },
};
```

### Change Daily Reset Time

Default: Midnight (00:00) UTC

```typescript
// In checkUsageLimit middleware
const nextReset = new Date(now);
nextReset.setDate(nextReset.getDate() + 1);
nextReset.setHours(0, 0, 0, 0); // Change hours here
```

---

## 💳 Stripe Integration (Next Step)

### 1. Create Products in Stripe

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe  # Mac
# or download from https://stripe.com/docs/stripe-cli

# Login
stripe login

# Create products
stripe products create --name="Pro Plan" --description="1000 calls/day"
stripe prices create --product=PRODUCT_ID --unit-amount=999 --currency=usd --recurring-interval=month
```

### 2. Add Webhook Handler

```typescript
// backend/src/routes/subscriptions.ts
router.post("/webhook", async (req, res) => {
  const sig = req.headers["stripe-signature"];
  const event = stripe.webhooks.constructEvent(req.body, sig, WEBHOOK_SECRET);

  if (event.type === "customer.subscription.created") {
    // Update user's subscriptionTier in database
  }
});
```

### 3. Frontend Checkout

```tsx
// frontend/src/components/SubscriptionCheckout.tsx
const handleUpgrade = async (tier: string) => {
  const res = await fetch("/api/subscriptions/create", {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` },
    body: JSON.stringify({ tier }),
  });
  const { checkoutUrl } = await res.json();
  window.location.href = checkoutUrl;
};
```

---

## 📈 Monitoring & Analytics

### Track Key Metrics

```sql
-- Daily revenue
SELECT DATE(created_at), COUNT(*),
       SUM(CASE WHEN "subscriptionTier" = 'PRO' THEN 9.99 ELSE 0 END) as revenue
FROM users
WHERE "subscriptionTier" != 'FREE'
GROUP BY DATE(created_at);

-- API usage by tier
SELECT "tierAtRequest", COUNT(*), AVG("responseTime")
FROM weather_api_usage
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY "tierAtRequest";

-- Most popular cities
SELECT city, COUNT(*) as requests
FROM weather_api_usage
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY city
ORDER BY requests DESC
LIMIT 10;
```

### Set Up Alerts

```typescript
// Alert when user hits 80% of limit
if (user.weatherApiCallsUsed / user.weatherApiCallsLimit > 0.8) {
  await sendEmail({
    to: user.email,
    subject: "80% API Limit Reached",
    template: "usage-warning",
  });
}
```

---

## 🐛 Troubleshooting

### "Weather service not configured"

**Solution**: Add `OPENWEATHERMAP_API_KEY` to `backend/.env`

### "Daily API call limit reached"

**Solution**: User exceeded their tier's daily limit. Wait for reset (midnight UTC) or upgrade tier.

### Migration fails

```bash
# Reset migrations (CAUTION: Drops tables)
cd backend
npx prisma migrate reset

# Or manually apply
npx prisma db push
```

### TypeScript errors in weatherSaas.ts

```bash
cd backend
npm install @prisma/client
npx prisma generate
```

---

## 🎯 Testing Subscription Tiers

### Manually Set User Tier

```sql
-- Upgrade user to PRO
UPDATE users
SET "subscriptionTier" = 'PRO',
    "weatherApiCallsLimit" = 1000
WHERE email = 'test@example.com';

-- Test Enterprise tier
UPDATE users
SET "subscriptionTier" = 'ENTERPRISE',
    "weatherApiCallsLimit" = 999999
WHERE email = 'admin@example.com';
```

### Test Rate Limiting

```bash
# Make 51 requests as FREE user (should hit limit)
for i in {1..51}; do
  curl -H "Authorization: Bearer YOUR_TOKEN" \
    "http://localhost:4000/api/weather?city=London"
  echo "\nRequest $i"
done
```

### Test Feature Gating

```bash
# Try forecast as FREE user (should get 403)
curl -H "Authorization: Bearer FREE_USER_TOKEN" \
  "http://localhost:4000/api/weather/forecast?city=London"

# Response: "This feature requires Pro subscription or higher"
```

---

## ✅ Launch Checklist

- [ ] Database migrations applied
- [ ] OpenWeatherMap API key configured
- [ ] All users have default subscription tier
- [ ] Frontend displays pricing correctly
- [ ] Rate limiting works per tier
- [ ] Feature gating blocks FREE users from Pro features
- [ ] Usage tracking records API calls
- [ ] Upgrade prompts show when limit hit
- [ ] Stripe products created
- [ ] Payment webhook configured
- [ ] Email notifications set up
- [ ] Analytics dashboard ready

---

**You're ready to launch a profitable Weather API SaaS! 🚀**

**Next Steps:**

1. Set up Stripe billing
2. Create landing page with pricing
3. Launch on Product Hunt
4. Start marketing to developers
