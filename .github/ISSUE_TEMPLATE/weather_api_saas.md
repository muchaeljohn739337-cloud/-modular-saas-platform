---
name: Weather API SaaS Implementation
about: Track implementation of tiered weather API service
title: "[FEATURE] Weather API SaaS with Tiered Subscriptions"
labels: "feature, enhancement, monetization, high-priority"
assignees: ""
---

## 🌦️ Feature Overview

**Transform the basic weather dashboard into a profitable SaaS product with tiered subscriptions.**

### Business Impact

- **Revenue Potential**: $50,000 - $360,000/year
- **Target Market**: Developers, businesses, IoT apps
- **Free Tier Conversion**: 5-10% to paid plans
- **Profit Margins**: 96%+ with caching

---

## 📋 Implementation Status

### ✅ Completed Components

- [x] Backend API with 8 endpoints
- [x] Prisma database schema (4 tiers)
- [x] Rate limiting middleware
- [x] Feature gating system
- [x] Usage tracking & analytics
- [x] Frontend SaaS dashboard
- [x] Pricing modal UI
- [x] Database migrations applied
- [x] Unit tests created
- [x] Comprehensive documentation

### ⚠️ Needs Configuration

- [ ] Set `OPENWEATHERMAP_API_KEY` in backend/.env
- [ ] Initialize user subscription tiers in database
- [ ] Test all API endpoints
- [ ] Integrate frontend navigation
- [ ] Verify rate limiting works

### 🚀 Optional (Phase 2)

- [ ] Stripe payment integration
- [ ] Email notifications for alerts
- [ ] Redis caching layer
- [ ] Admin analytics dashboard
- [ ] API key management UI

---

## 🎯 Subscription Tiers

| Tier           | Price      | Calls/Day | Features            | Target Users |
| -------------- | ---------- | --------- | ------------------- | ------------ |
| **FREE**       | $0         | 50        | Current weather     | Hobbyists    |
| **PRO**        | $29.99/mo  | 1,000     | + Forecast + Alerts | Developers   |
| **BUSINESS**   | $99.99/mo  | 5,000     | + Batch + Priority  | Startups     |
| **ENTERPRISE** | $299.99/mo | 25,000    | + Custom + Webhook  | Enterprises  |

---

## 🛠️ Technical Details

### Backend Architecture

- **Framework**: Express.js + TypeScript
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: JWT tokens
- **API Provider**: OpenWeatherMap (free tier: 60/min, 1M/month)

### API Endpoints

```
GET    /api/weather/pricing          # Public pricing info
GET    /api/weather/usage            # User's current usage stats
GET    /api/weather?city=London      # Current weather (all tiers)
GET    /api/weather/forecast?city=X  # 5-day forecast (Pro+)
POST   /api/weather/batch            # Batch lookups (Business+)
POST   /api/weather/alerts           # Create alert (Pro+)
GET    /api/weather/alerts           # List user's alerts
DELETE /api/weather/alerts/:id       # Delete alert
```

### Database Schema

```prisma
enum SubscriptionTier {
  FREE
  PRO
  BUSINESS
  ENTERPRISE
}

model User {
  subscriptionTier         SubscriptionTier @default(FREE)
  weatherApiCallsUsed      Int              @default(0)
  weatherApiCallsLimit     Int              @default(50)
  weatherApiCallsResetAt   DateTime?
  // ... other fields
}

model WeatherApiUsage {
  id           Int      @id @default(autoincrement())
  userId       Int
  endpoint     String
  city         String?
  responseTime Int
  cached       Boolean  @default(false)
  tierAtRequest String
  createdAt    DateTime @default(now())
  user         User     @relation(...)
}

model WeatherAlert {
  id          Int      @id @default(autoincrement())
  userId      Int
  city        String
  condition   String   // "temp_above", "temp_below", "rain", etc.
  threshold   Float?
  enabled     Boolean  @default(true)
  notifyEmail Boolean  @default(true)
  notifyWebhook Boolean @default(false)
  webhookUrl  String?
  createdAt   DateTime @default(now())
  user        User     @relation(...)
}
```

---

## 🧪 Testing Checklist

### Manual API Testing

```bash
# 1. Test pricing endpoint (public, no auth)
curl http://localhost:4000/api/weather/pricing

# 2. Get JWT token (login first)
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# 3. Test current weather (requires auth)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  "http://localhost:4000/api/weather?city=London&units=metric"

# 4. Test usage stats
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:4000/api/weather/usage

# 5. Test forecast (Pro+ only)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  "http://localhost:4000/api/weather/forecast?city=Paris&units=metric"

# 6. Test rate limiting (make 51 requests on free tier)
for i in {1..51}; do
  curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
    "http://localhost:4000/api/weather?city=London"
done
# Expected: First 50 succeed, 51st returns 429 Too Many Requests
```

### Feature Testing

- [ ] **Rate Limiting**: Free tier blocked after 50 calls
- [ ] **Feature Gating**: Free users can't access forecast
- [ ] **Usage Tracking**: API calls increment counter
- [ ] **Daily Reset**: Limits reset at midnight UTC
- [ ] **Tier Badge**: Correct tier shown in dashboard
- [ ] **Upgrade CTAs**: Prompts appear when near limit
- [ ] **Pricing Modal**: All 4 tiers display correctly
- [ ] **Error Handling**: Invalid city returns 404

---

## 🚀 Deployment Steps

### 1. Environment Setup

```bash
# backend/.env (add these)
OPENWEATHERMAP_API_KEY=your_key_from_openweathermap.org
DATABASE_URL=postgresql://...
JWT_SECRET=your_secret_key
```

### 2. Database Initialization

```bash
cd backend
npx prisma migrate deploy  # Apply migrations
npx prisma studio          # Optional: verify schema
```

### 3. Initialize Existing Users

```sql
-- Run in Prisma Studio or psql
UPDATE users SET
  "subscriptionTier" = 'FREE',
  "weatherApiCallsLimit" = 50,
  "weatherApiCallsUsed" = 0,
  "weatherApiCallsResetAt" = NOW() + INTERVAL '1 day'
WHERE "subscriptionTier" IS NULL;
```

### 4. Start Services

```bash
# Terminal 1: Backend
cd backend
npm run dev  # Runs on port 4000

# Terminal 2: Frontend
cd frontend
npm run dev  # Runs on port 3000
```

### 5. Test in Browser

- Navigate to `http://localhost:3000/weather`
- Login with test account
- Verify usage stats display
- Click "View Pricing" to see tiers
- Make API requests and watch counter increment

---

## 👥 Team Assignments

### Backend Team

- **Task**: API optimization & caching
- **Priority**: HIGH
- **Files**: `backend/src/routes/weatherSaas.ts`
- **Deliverables**:
  - [ ] Add Redis caching for popular cities
  - [ ] Optimize database queries
  - [ ] Add request logging
  - [ ] Write integration tests

### Frontend Team

- **Task**: UI polish & integration
- **Priority**: MEDIUM
- **Files**: `frontend/src/components/WeatherSaaSDashboard.tsx`
- **Deliverables**:
  - [ ] Add to main navigation menu
  - [ ] Improve loading states
  - [ ] Add error boundary
  - [ ] Mobile responsiveness check

### DevOps Team

- **Task**: Deployment & monitoring
- **Priority**: MEDIUM
- **Files**: `docker-compose.yml`, CI/CD configs
- **Deliverables**:
  - [ ] Update Docker compose
  - [ ] Add environment variables to CI/CD
  - [ ] Set up monitoring alerts
  - [ ] Document rollback procedure

### QA Team

- **Task**: Testing & validation
- **Priority**: HIGH
- **Files**: Test suites
- **Deliverables**:
  - [ ] Execute manual test plan
  - [ ] Write automated E2E tests
  - [ ] Load testing (1000 concurrent users)
  - [ ] Security audit

---

## 📊 Success Metrics

### Week 1 (MVP)

- [ ] 100% uptime
- [ ] <500ms average response time
- [ ] 0 critical bugs
- [ ] 10+ test users signed up

### Month 1

- [ ] 100 free tier users
- [ ] 5-10 Pro subscribers ($150-300 MRR)
- [ ] 70%+ cache hit rate
- [ ] <1% error rate

### Quarter 1

- [ ] 500 total users
- [ ] 25-50 paid subscribers ($750-1500 MRR)
- [ ] 1-2 Business tier customers
- [ ] 95% user satisfaction

### Year 1

- [ ] 2,000+ users
- [ ] 100-200 paid subscribers ($3K-6K MRR)
- [ ] 5-10 Enterprise clients
- [ ] Break even + profit

---

## 🔧 Troubleshooting

### "Weather service not configured"

**Cause**: Missing `OPENWEATHERMAP_API_KEY` in environment  
**Fix**: Add key to `backend/.env`

### "subscriptionTier is null" error

**Cause**: Existing users don't have tier assigned  
**Fix**: Run SQL update query above

### Rate limit not working

**Cause**: Database connection or migration issue  
**Fix**: Run `npx prisma migrate status` and verify

### Frontend shows blank data

**Cause**: CORS issue or backend not running  
**Fix**: Check backend logs, verify `allowedOrigins` in config

---

## 📚 Documentation References

- **Business Model**: `WEATHER_SAAS_BUSINESS_MODEL.md`
- **Setup Guide**: `WEATHER_SAAS_SETUP.md`
- **API Docs**: `WEATHER_SAAS_README.md`
- **Implementation Checklist**: `.github/WEATHER_API_IMPLEMENTATION_CHECKLIST.md`

---

## 💬 Discussion Points

### Questions

1. Should we start with Stripe integration or manual tier upgrades?
2. Do we need a separate admin panel for subscription management?
3. Should alerts support SMS notifications (Twilio)?
4. What's our backup plan if OpenWeatherMap rate limits us?

### Concerns

- **API Costs**: Monitor OpenWeatherMap usage to stay under 1M/month
- **Caching**: Redis required for profitability at scale
- **Compliance**: GDPR for EU users, data retention policies
- **Competition**: AccuWeather, WeatherStack offer similar APIs

### Next Steps

- [ ] Review this issue with team
- [ ] Assign tasks to respective teams
- [ ] Set sprint goals (2-week sprint)
- [ ] Schedule demo for stakeholders

---

**Created**: November 16, 2025  
**Status**: Implementation Complete, Testing Needed  
**Priority**: HIGH  
**Estimated Time**: 2-3 weeks to production
