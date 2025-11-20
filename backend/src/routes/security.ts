import { Router } from "express";
import { authenticateToken } from "../middleware/auth";
import prisma from "../prismaClient";

const router = Router();

// Check for data breaches
router.get("/breach-check", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { email: true },
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // In production, integrate with Have I Been Pwned API or similar
    // For now, return demo data structure
    const breaches = [
      {
        email: user.email,
        breachCount: 0,
        sources: [],
      },
    ];

    const totalBreaches = 0;
    const monitoring = false; // Check user settings

    res.json({
      breaches,
      totalBreaches,
      monitoring,
    });
  } catch (error) {
    console.error("Breach check error:", error);
    res.status(500).json({ error: "Failed to check breaches" });
  }
});

// Activate breach monitoring
router.post("/activate-monitoring", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    // Update user settings to enable monitoring
    await prisma.user.update({
      where: { id: userId },
      data: {
        // Add a breachMonitoring field to User model
        // breachMonitoring: true,
      },
    });

    res.json({ success: true, monitoring: true });
  } catch (error) {
    console.error("Monitoring activation error:", error);
    res.status(500).json({ error: "Failed to activate monitoring" });
  }
});

// Rotate IP (proxy/VPN simulation)
router.post("/rotate-ip", authenticateToken, async (req, res) => {
  try {
    const { targetCountry } = req.body;

    // In production, integrate with proxy/VPN provider API
    // For demo, generate random IP based on country
    const ipRanges: Record<string, string> = {
      "United States": "104.",
      "United Kingdom": "86.",
      Germany: "217.",
      France: "89.",
      Canada: "142.",
      Australia: "1.",
      Japan: "153.",
      Singapore: "103.",
    };

    const prefix = ipRanges[targetCountry] || "104.";
    const newIP = `${prefix}${Math.floor(Math.random() * 256)}.${Math.floor(
      Math.random() * 256
    )}.${Math.floor(Math.random() * 256)}`;

    const cities: Record<string, string> = {
      "United States": "New York",
      "United Kingdom": "London",
      Germany: "Berlin",
      France: "Paris",
      Canada: "Toronto",
      Australia: "Sydney",
      Japan: "Tokyo",
      Singapore: "Singapore",
    };

    res.json({
      success: true,
      newIP,
      country: targetCountry,
      city: cities[targetCountry] || "Unknown",
      protected: true,
    });
  } catch (error) {
    console.error("IP rotation error:", error);
    res.status(500).json({ error: "Failed to rotate IP" });
  }
});

// Get current IP info
router.get("/ip-info", authenticateToken, async (req, res) => {
  try {
    // Get client IP
    const clientIP =
      req.headers["x-forwarded-for"]?.toString().split(",")[0] ||
      req.headers["x-real-ip"]?.toString() ||
      req.socket.remoteAddress ||
      "Unknown";

    res.json({
      ip: clientIP,
      protected: false,
    });
  } catch (error) {
    console.error("IP info error:", error);
    res.status(500).json({ error: "Failed to get IP info" });
  }
});

export default router;
