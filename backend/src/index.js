import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./config/swagger.js";
import { runMigrations } from "./db.js";
import {
  errorHandler,
  initMonitoring,
  requestMetrics,
  securityHeaders,
} from "./middleware/protection.js";
import authRoutes from "./routes/auth.js";
import healthRoutes from "./routes/health.js";
import { seedAdmin } from "./seed.js";
import {
  initSentry,
  sentryErrorHandler,
  sentryRequestHandler,
  sentryTracingHandler,
} from "./utils/sentry.js";

dotenv.config();

// Initialize Sentry FIRST (before any other code)
initSentry();

// Initialize monitoring
initMonitoring();

const app = express();
const PORT = process.env.PORT || 4000;

// Sentry request handler must be first middleware
app.use(sentryRequestHandler());
app.use(sentryTracingHandler());

// Apply security headers globally
securityHeaders(app);

// Apply request metrics
requestMetrics(app);

app.use(cors({ origin: "*" }));
app.use(express.json());

// Swagger API Documentation
app.use(
  "/api-docs",
  swaggerUi.serve,
  swaggerUi.setup(swaggerSpec, {
    explorer: true,
    customCss: ".swagger-ui .topbar { display: none }",
    customSiteTitle: "Advancia Pay API Docs",
  })
);

// Swagger JSON endpoint
app.get("/api-docs.json", (req, res) => {
  res.setHeader("Content-Type", "application/json");
  res.send(swaggerSpec);
});

app.use("/api", healthRoutes);
app.use("/api/auth", authRoutes);
// Test-only endpoints
import testRoutes from "./routes/test.js";
app.use("/api/test", testRoutes);
// Weather SaaS API
import weatherSaasRoutes from "./routes/weatherSaas.js";
app.use("/api/weather", weatherSaasRoutes);

app.get("/api/me", (req, res) =>
  res.json({ service: "advvancia-backend", version: "1.0.0" })
);

// Sentry error handler must be before other error handlers
app.use(sentryErrorHandler());

// Global error handler (last middleware)
app.use(errorHandler);

// Run migrations at startup
console.log("🚀 Starting backend initialization...");

runMigrations()
  .then(() => {
    console.log("✅ Database migrations completed");
    return seedAdmin();
  })
  .then(() => {
    console.log("✅ Admin user seeded/verified");
    return import("./seed.js").then((m) => m.seedTestUser && m.seedTestUser());
  })
  .then(() => {
    console.log("✅ Test user seeded/verified");
    console.log("🌐 Starting HTTP server...");

    const server = app.listen(PORT, () => {
      console.log(`✅ Backend listening on port ${PORT}`);
      console.log(`📍 Health: http://localhost:${PORT}/api/health`);
      console.log(`📍 API Docs: http://localhost:${PORT}/api-docs`);
      console.log(`🌦️  Weather API: http://localhost:${PORT}/api/weather/test`);
      console.log("🎉 Server is ready to accept connections!");
    });

    // Keep the process alive
    server.on("error", (error) => {
      console.error("❌ Server error:", error);
      process.exit(1);
    });

    // Handle graceful shutdown
    process.on("SIGINT", () => {
      console.log("\n⏳ Gracefully shutting down...");
      server.close(() => {
        console.log("✅ Server closed");
        process.exit(0);
      });
    });
  })
  .catch((err) => {
    console.error("❌ Startup error:", err);
    console.error("Stack trace:", err.stack);
    process.exit(1);
  });
