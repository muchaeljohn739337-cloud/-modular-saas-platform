import rateLimit from "express-rate-limit";
import helmet from "helmet";
import { z } from "zod";

// ✅ Security headers
export function securityHeaders(app) {
  app.use(
    helmet({
      contentSecurityPolicy: false, // adjust if serving frontend
      crossOriginResourcePolicy: { policy: "same-origin" },
    }),
  );
}

// ✅ Rate limiting (example: login endpoint)
export const loginLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // limit each IP to 5 requests/minute
  message: { error: "Too many login attempts, try again later." },
});

// ✅ Response sanitizer
export function sanitizeUser(user) {
  return {
    id: user.id,
    email: user.email,
    role: user.role,
    created_at: user.created_at,
    // exclude password_hash, tokens, etc.
  };
}

// ✅ Response validation schema
export const userSchema = z.object({
  id: z.number(),
  email: z.string().email(),
  role: z.string(),
  created_at: z.string(),
});

// ✅ Global error handler
export function errorHandler(err, req, res, next) {
  console.error(err); // log internally
  res.status(err.status || 500).json({
    ok: false,
    error: err.message || "Internal server error",
  });
}
