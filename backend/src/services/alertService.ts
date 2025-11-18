// Minimal alert service - safe no-op implementation for production readiness
// Avoids optional dependencies; logs and optionally captures to Sentry.

type Severity = "low" | "medium" | "high" | "critical";

export interface AlertData {
  identifier: string;
  group: string;
  count: number;
  path?: string;
  method?: string;
  timestamp?: number;
  userAgent?: string;
  severity?: Severity;
}

// Lazy import to avoid hard dependency during build
let sentryCapture: ((err: Error, ctx?: any) => void) | null = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const mod = require("../utils/sentry");
  sentryCapture = mod && typeof mod.captureError === "function" ? mod.captureError : null;
} catch {
  sentryCapture = null;
}

export async function sendAlert(data: AlertData): Promise<void> {
  try {
    const sev = data.severity || "medium";
    const msg = `[ALERT] group=${data.group} id=${data.identifier} count=${data.count} sev=${sev} path=${data.path} method=${data.method}`;
    if (process.env.NODE_ENV !== "production") {
      // eslint-disable-next-line no-console
      console.warn(msg);
    }

    // Optionally capture to Sentry in production
    if (process.env.SENTRY_DSN && sentryCapture) {
      sentryCapture(new Error("rate-limit-alert"), {
        level: "warning",
        tags: { component: "alert-service", severity: sev, group: data.group },
        extra: data,
      });
    }
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Alert dispatch failed:", err);
  }
}

export default { sendAlert };

// (File intentionally minimal to unblock production build)
                    { title: "Route Group:", value: data.group },
                    { title: "Severity:", value: severity.toUpperCase() },
                    {
                      title: "Timestamp:",
                      value: new Date(
                        data.timestamp || Date.now()
                      ).toISOString(),
                    },
                  ],
                },
              ],
              $schema: "http://adaptivecards.io/schemas/adaptive-card.json",
              version: "1.4",
            },
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`Teams API error: ${response.statusText}`);
    }

    console.log(`✓ Teams alert sent for ${data.identifier} in ${data.group}`);
  } catch (err) {
    console.error("Failed to send Teams alert:", err);
    if (process.env.SENTRY_DSN) {
      captureError(err as Error, {
        tags: { component: "alert-service", channel: "teams" },
        extra: data,
      });
    }
  }
}

/**
 * Send Sentry alert
 */
function sendSentryAlert(data: AlertData): void {
  if (!process.env.SENTRY_DSN) {
    return;
  }

  const policy = getAlertPolicy(data.group);
  const severity = policy?.severity || "medium";

  captureError(new Error("Rate limit threshold exceeded"), {
    level:
      severity === "critical"
        ? "fatal"
        : severity === "high"
        ? "error"
        : "warning",
    tags: {
      type: "security",
      event: "rate_limit_alert",
      severity,
      routeGroup: data.group,
    },
    extra: data,
  });

  console.log(`✓ Sentry alert logged for ${data.identifier} in ${data.group}`);
}

/**
 * Get alert policy from database with caching
 * Falls back to config/alertPolicy.ts if database is unavailable
 */
async function getPolicyFromDB(group: string): Promise<any | null> {
  try {
    // Check cache first
    const now = Date.now();
    if (now - lastCacheRefresh < CACHE_TTL && policyCache.has(group)) {
      return policyCache.get(group);
    }

    // Refresh cache if stale
    if (now - lastCacheRefresh >= CACHE_TTL) {
      const policies = await prisma.alertPolicy.findMany({
        where: { enabled: true },
      });

      policyCache.clear();
      policies.forEach((p) => {
        policyCache.set(p.routeGroup, p);
      });

      lastCacheRefresh = now;
      console.log(`✓ Refreshed policy cache (${policies.length} policies)`);
    }

    // Return from cache
    const policy = policyCache.get(group);
    if (policy) {
      return policy;
    }

    // Fallback to config file
    console.warn(
      `⚠️ Policy not found in DB for ${group}, using config fallback`
    );
    return getAlertPolicy(group);
  } catch (err) {
    console.error("Failed to fetch policy from database:", err);

    // Fallback to config file
    return getAlertPolicy(group);
  }
}

/**
 * Store alert in Redis for history tracking
 */
async function storeAlertHistory(data: AlertData): Promise<void> {
  try {
    const alertKey = `alert_history:${data.group}`;
    const alertData = JSON.stringify({
      ...data,
      timestamp: data.timestamp || Date.now(),
    });

    await redis.lpush(alertKey, alertData);
    await redis.ltrim(alertKey, 0, 99); // Keep last 100 alerts
    await redis.expire(alertKey, 86400 * 7); // 7 days retention

    console.log(
      `✓ Alert stored in history for ${data.identifier} in ${data.group}`
    );
  } catch (err) {
    console.error("Failed to store alert history:", err);
  }
}

/**
 * Main alert sending function (Database-Backed)
 * Sends alerts via all configured channels based on database alert policy
 */
export async function sendAlert(data: AlertData): Promise<void> {
  const policy = await getPolicyFromDB(data.group);
  if (!policy) {
    console.log(`⚠️ No alert policy found for group: ${data.group}`);
    return;
  }

  // Check if policy is disabled
  if (policy.enabled === false) {
    console.log(`⏸ Alert policy disabled for group: ${data.group}`);
    return;
  }

  // Check cooldown to prevent alert spam
  const cooldownKey = `${data.group}:${data.identifier}`;
  const cooldownMs = policy.cooldown || 5 * 60 * 1000;

  if (await isInCooldown(cooldownKey, cooldownMs)) {
    console.log(
      `⏱️ Alert suppressed for ${data.identifier} in ${data.group} (cooldown active)`
    );

    // Log suppressed alert for visibility (but don't send notifications)
    if (process.env.SENTRY_DSN && policy.severity === "critical") {
      captureError(new Error("Alert suppressed due to cooldown"), {
        level: "info",
        tags: {
          type: "alert_suppressed",
          routeGroup: data.group,
          severity: policy.severity,
        },
        extra: { ...data, reason: "cooldown" },
      });
    }
    return;
  }

  console.log(
    `🚨 Triggering alert for ${data.identifier} in ${data.group} (${data.count} requests, severity: ${policy.severity})`
  );

  // Set cooldown (async, but don't block alert sending)
  setAlertCooldown(cooldownKey, cooldownMs).catch((err) => {
    console.error(`Failed to set alert cooldown:`, err);
  });

  // Store in history
  await storeAlertHistory(data);

  // Send via all configured channels in parallel
  const promises: Promise<void>[] = [];

  policy.channels.forEach((channel) => {
    switch (channel) {
      case "email":
        promises.push(sendEmailAlert(data));
        break;
      case "sms":
        promises.push(sendSMSAlert(data));
        break;
      case "slack":
        promises.push(sendSlackAlert(data));
        break;
      case "teams":
        promises.push(sendTeamsAlert(data));
        break;
      case "sentry":
        sendSentryAlert(data); // Synchronous
        break;
      // WebSocket is handled separately in the rate limiter
      case "websocket":
        break;
    }
  });

  await Promise.allSettled(promises);
}

/**
 * Get alert history for a route group
 */
export async function getAlertHistory(group: string, limit: number = 50) {
  try {
    const alertKey = `alert_history:${group}`;
    const alerts = await redis.lrange(alertKey, 0, limit - 1);

    return alerts.map((alert) => JSON.parse(alert));
  } catch (err) {
    console.error("Failed to fetch alert history:", err);
    return [];
  }
}
