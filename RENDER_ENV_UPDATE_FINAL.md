# 🚀 Final Render Environment Variable Updates

**Service**: advancia-backend (srv-d4froq8gjchc73djvp00)
**Date**: November 20, 2025
**URL**: https://dashboard.render.com/web/srv-d4froq8gjchc73djvp00/env

---

## ✅ STEP 1: DELETE These 3 Variables

Click ❌ to delete:

1. `SENTRY_DSN` (invalid hash)
2. `VAPID_PUBLIC_KEY` (invalid hash)
3. `VAPID_PRIVATE_KEY` (invalid hash)

---

## ✅ STEP 2: ADD These 3 New Variables

### Variable 1: VAPID_PUBLIC_KEY

```
Key: VAPID_PUBLIC_KEY
Value: BJmfJtNJI4OHutTbB3smUURJltgZCysjoOo3fQcmaUmOIJS_n1K0cjDjp_9yZlas0TxyOj37otHkXnNs0_vx-Wo
```

### Variable 2: VAPID_PRIVATE_KEY

```
Key: VAPID_PRIVATE_KEY
Value: 5B0_yOZoG3xH7L6kSCDQi5a1uUN_Oy9KvUXyj51fW4s
```

### Variable 3: STRIPE_WEBHOOK_SECRET

```
Key: STRIPE_WEBHOOK_SECRET
Value: whsec_yCcQbvfb1lH1JEeUTyNvhvATXMc2kcUl
```

---

## ✅ STEP 3: Save Changes

Click **"Save Changes"** button at bottom of page

Render will automatically redeploy (takes 2-3 minutes)

---

## ✅ STEP 4: Test After Deployment

Wait for deployment to complete, then run:

```bash
curl https://api.advanciapayledger.com/api/health
```

**Expected Response:**

```json
{ "status": "healthy", "timestamp": "2025-11-20T..." }
```

---

## 📊 Summary of Changes

| Variable                | Old Value                          | New Value        | Status      |
| ----------------------- | ---------------------------------- | ---------------- | ----------- |
| `SENTRY_DSN`            | `3040155bb82e661cf67afc469c94b5cc` | (deleted)        | ✅ Optional |
| `VAPID_PUBLIC_KEY`      | `3156d55b58b3c102690c2fad5feaf870` | `BJmfJtNJI4O...` | ✅ Fixed    |
| `VAPID_PRIVATE_KEY`     | `2ee5739dd2db4ea32f65e15c17953831` | `5B0_yOZoG3x...` | ✅ Fixed    |
| `STRIPE_WEBHOOK_SECRET` | `f097258e80bb8dc2e625c5858297ab9a` | `whsec_yCcQ...`  | ✅ Fixed    |

---

## 🎯 What This Fixes

- ✅ **502 Bad Gateway** → Backend will start successfully
- ✅ **Web Push Notifications** → VAPID keys now valid
- ✅ **Stripe Webhooks** → Payment events will be received and verified
- ✅ **Real-time Updates** → Socket.IO will work for payment status

---

## 🔗 Stripe Webhook Configuration

**Endpoint URL**: `https://api.advanciapayledger.com/api/payments/webhook`

**Events Configured**:

- ✅ `payment_intent.succeeded`
- ✅ `payment_intent.payment_failed`
- ✅ `payment_intent.canceled`

**Webhook Secret**: `whsec_yCcQbvfb1lH1JEeUTyNvhvATXMc2kcUl`

View in Dashboard: https://dashboard.stripe.com/test/webhooks

---

## 📝 Next Steps After Backend Is Live

1. ✅ Test health endpoint
2. ✅ Test a Stripe payment to verify webhook receives events
3. ✅ Check Render logs for successful webhook processing
4. ✅ Test Cryptomus crypto payments
5. ✅ Configure Cryptomus webhook URL if not already done

---

**Ready to update Render?** Go to:
https://dashboard.render.com/web/srv-d4froq8gjchc73djvp00/env
