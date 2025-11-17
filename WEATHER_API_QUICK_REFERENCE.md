# ⚡ Weather API SaaS - Quick Command Reference

## 🚀 Get Started in 5 Minutes

### 1. Configure API Key (2 min)

```bash
# Get free key from https://openweathermap.org/api
cd backend
echo "OPENWEATHERMAP_API_KEY=your_api_key_here" >> .env
```

### 2. Setup Database (1 min)

```bash
cd backend
npx prisma migrate deploy
```

### 3. Start Servers (2 min)

```bash
# Terminal 1: Backend
cd backend && npm run dev

# Terminal 2: Frontend
cd frontend && npm run dev
```

---

## 🧪 Test API Endpoints

### Get Pricing (No Auth)

```bash
curl http://localhost:4000/api/weather/pricing | jq
```

**Expected Response:**

```json
{
  "tiers": [
    {
      "name": "FREE",
      "price": 0,
      "callsPerDay": 50,
      "features": ["Current weather", "Basic forecasts"]
    },
    {
      "name": "PRO",
      "price": 29.99,
      "callsPerDay": 1000,
      "features": ["Current weather", "5-day forecasts", "Weather alerts"]
    }
  ]
}
```

---

### Login to Get Token

```bash
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' | jq

# Copy the "token" from response and use in next commands
export TOKEN="your_jwt_token_here"
```

---

### Get Current Weather

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:4000/api/weather?city=London&units=metric" | jq
```

**Expected Response:**

```json
{
  "success": true,
  "data": {
    "city": "London",
    "temperature": 15.2,
    "feels_like": 14.1,
    "description": "Partly cloudy",
    "humidity": 72,
    "wind_speed": 5.3
  },
  "usage": {
    "used": 1,
    "limit": 50,
    "remaining": 49
  }
}
```

---

### Check Usage Stats

```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/weather/usage | jq
```

**Expected Response:**

```json
{
  "tier": "FREE",
  "callsUsed": 1,
  "callsLimit": 50,
  "callsRemaining": 49,
  "resetAt": "2025-11-17T00:00:00.000Z",
  "percentageUsed": 2
}
```

---

### Get 5-Day Forecast (Pro+ Only)

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:4000/api/weather/forecast?city=Paris&units=metric" | jq
```

**Free Tier Response:**

```json
{
  "error": "This feature requires PRO subscription or higher"
}
```

**Pro Tier Response:**

```json
{
  "success": true,
  "data": {
    "city": "Paris",
    "forecast": [
      {
        "date": "2025-11-17",
        "temp_max": 18.5,
        "temp_min": 12.3,
        "description": "Sunny"
      }
    ]
  }
}
```

---

### Test Rate Limiting

```bash
# Make 51 requests (free tier limit is 50/day)
for i in {1..51}; do
  echo "Request $i:"
  curl -s -H "Authorization: Bearer $TOKEN" \
    "http://localhost:4000/api/weather?city=London" | jq -r '.usage // .error'
done
```

**Expected Output:**

```
Request 1: { "used": 1, "limit": 50, "remaining": 49 }
Request 2: { "used": 2, "limit": 50, "remaining": 48 }
...
Request 50: { "used": 50, "limit": 50, "remaining": 0 }
Request 51: Daily API limit exceeded. Upgrade to PRO for 1,000 calls/day.
```

---

## 📊 Database Operations

### View Current Schema

```bash
cd backend
npx prisma studio
# Opens browser at http://localhost:5555
# Navigate to: User, WeatherApiUsage, WeatherAlert tables
```

### Initialize Existing Users

```sql
-- Run in Prisma Studio or psql
UPDATE users SET
  "subscriptionTier" = 'FREE',
  "weatherApiCallsLimit" = 50,
  "weatherApiCallsUsed" = 0,
  "weatherApiCallsResetAt" = NOW() + INTERVAL '1 day'
WHERE "subscriptionTier" IS NULL;
```

### Check Migration Status

```bash
cd backend
npx prisma migrate status
```

**Expected Output:**

```
Database schema is up to date!
4 migrations found in prisma/migrations
```

### View User's API Usage

```sql
-- In Prisma Studio
SELECT * FROM "WeatherApiUsage"
WHERE "userId" = 1
ORDER BY "createdAt" DESC
LIMIT 10;
```

---

## 🎨 Frontend Testing

### Open Dashboard in Browser

```
http://localhost:3000/weather
```

### Manual Test Checklist

- [ ] Login page redirects to dashboard
- [ ] Tier badge shows "FREE" (or current tier)
- [ ] Usage stats display: "1 / 50 calls used"
- [ ] Progress bar shows correct percentage
- [ ] "View Pricing" button opens modal
- [ ] Pricing modal shows all 4 tiers
- [ ] Make 5 requests → counter increments
- [ ] Reach 80% → Upgrade CTA appears
- [ ] Reach 100% → Error message with upgrade link

---

## 🐛 Troubleshooting

### "Weather service not configured"

```bash
# Check if API key is set
cd backend
grep OPENWEATHERMAP_API_KEY .env

# If empty, add it:
echo "OPENWEATHERMAP_API_KEY=your_key_here" >> .env

# Restart backend
npm run dev
```

---

### "subscriptionTier is null" Error

```bash
# Initialize users in database
cd backend
npx prisma studio
# Run SQL update query above
```

---

### Backend Won't Start

```bash
# Check for port conflicts
netstat -ano | findstr :4000

# If port is in use, kill process or change port
# In backend/src/index.ts, change PORT

# Check database connection
cd backend
npx prisma db pull
# Should succeed if DATABASE_URL is correct
```

---

### Frontend Shows Blank Data

```bash
# Check backend is running
curl http://localhost:4000/api/weather/pricing

# Check CORS settings in backend/src/config/index.ts
# Should include http://localhost:3000

# Check browser console for errors
# Press F12 → Console tab
```

---

## 📦 Deployment Commands

### Docker Compose (Full Stack)

```bash
# Build and start all services
docker-compose up -d

# Check logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Manual Deployment

#### Backend

```bash
cd backend
npm install
npx prisma migrate deploy
npm run build
npm start
```

#### Frontend

```bash
cd frontend
npm install
npm run build
npm start
```

---

## 🔧 Development Utilities

### Generate Prisma Client

```bash
cd backend
npx prisma generate
```

### Run Backend Tests

```bash
cd backend
npm test
# Runs Jest tests including weather endpoint tests
```

### Format Code

```bash
# Backend
cd backend
npm run format

# Frontend
cd frontend
npm run format
```

### Check TypeScript Errors

```bash
# Backend
cd backend
npx tsc --noEmit

# Frontend
cd frontend
npx tsc --noEmit
```

---

## 📈 Analytics Queries

### Most Popular Cities

```sql
SELECT city, COUNT(*) as requests
FROM "WeatherApiUsage"
WHERE city IS NOT NULL
GROUP BY city
ORDER BY requests DESC
LIMIT 10;
```

### Usage by Tier

```sql
SELECT "tierAtRequest", COUNT(*) as requests,
       AVG("responseTime") as avg_response_ms
FROM "WeatherApiUsage"
GROUP BY "tierAtRequest";
```

### Cache Hit Rate

```sql
SELECT
  COUNT(*) FILTER (WHERE cached = true) * 100.0 / COUNT(*) as cache_hit_rate,
  COUNT(*) as total_requests
FROM "WeatherApiUsage";
```

### Daily Revenue (Simulated)

```sql
SELECT COUNT(*) * 29.99 as estimated_monthly_revenue
FROM users
WHERE "subscriptionTier" = 'PRO';
```

---

## 🚀 Production Checklist

### Before Going Live

```bash
# 1. Set production API key
export OPENWEATHERMAP_API_KEY=prod_key

# 2. Use production database URL
export DATABASE_URL=postgresql://prod...

# 3. Generate strong JWT secret
export JWT_SECRET=$(openssl rand -base64 32)

# 4. Set CORS to production domain
export CORS_ORIGIN=https://yourdomain.com

# 5. Apply migrations
cd backend && npx prisma migrate deploy

# 6. Build frontend
cd frontend && npm run build

# 7. Start with PM2 (process manager)
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

---

## 📚 Quick Links

- **OpenWeatherMap API Docs**: https://openweathermap.org/api
- **Prisma Docs**: https://www.prisma.io/docs
- **Next.js Docs**: https://nextjs.org/docs
- **Express Docs**: https://expressjs.com

---

## 💡 Pro Tips

### Increase Rate Limits for Testing

```typescript
// In backend/src/routes/weatherSaas.ts
const TIER_LIMITS = {
  FREE: {
    callsPerDay: 5000, // Temporarily increase for testing
    // ...
  },
};
```

### Mock OpenWeatherMap API (Avoid Hitting Limits)

```typescript
// In backend/src/routes/weatherSaas.ts
// Replace axios call with:
const mockResponse = {
  name: city,
  main: { temp: 20, feels_like: 18, humidity: 65 },
  weather: [{ description: "Clear sky" }],
  wind: { speed: 3.5 },
};
```

### Reset User's Daily Limit

```sql
UPDATE users
SET "weatherApiCallsUsed" = 0,
    "weatherApiCallsResetAt" = NOW() + INTERVAL '1 day'
WHERE id = 1;
```

---

**Last Updated**: November 16, 2025  
**Version**: 1.0.0  
**Support**: See WEATHER_SAAS_SETUP.md for detailed documentation
