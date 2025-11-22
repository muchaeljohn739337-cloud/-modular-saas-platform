import { Router } from "express";
import { authenticateToken } from "../middleware/auth";
import prisma from "../prismaClient";

const router = Router();

// Check for data breaches
router.get("/breach-check", authenticateToken, async (req: any, res) => {
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
router.post(
  "/activate-monitoring",
  authenticateToken,
  async (req: any, res) => {
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
  }
);

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

// ============= IP Whitelist Endpoints =============

// Get user's whitelisted IPs
router.get("/whitelist/ips", authenticateToken, async (req: any, res) => {
  try {
    const userId = req.user.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { whitelistedIPs: true },
    });

    res.json({
      success: true,
      ips: user?.whitelistedIPs || [],
    });
  } catch (error) {
    console.error("Get whitelisted IPs error:", error);
    res.status(500).json({ error: "Failed to retrieve whitelisted IPs" });
  }
});

// Add whitelisted IP
router.post("/whitelist/ip", authenticateToken, async (req: any, res) => {
  try {
    const { ip, label } = req.body;
    const userId = req.user.userId;

    if (!ip) {
      return res.status(400).json({ error: "IP address is required" });
    }

    // Validate IP format (basic validation)
    const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (!ipRegex.test(ip)) {
      return res.status(400).json({ error: "Invalid IP address format" });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { whitelistedIPs: true },
    });

    if (user?.whitelistedIPs.includes(ip)) {
      return res.status(400).json({ error: "IP already whitelisted" });
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        whitelistedIPs: {
          push: ip,
        },
      },
    });

    res.json({
      success: true,
      message: `IP ${ip} added to whitelist`,
      ips: updatedUser.whitelistedIPs,
    });
  } catch (error) {
    console.error("Add whitelisted IP error:", error);
    res.status(500).json({ error: "Failed to add IP to whitelist" });
  }
});

// Remove whitelisted IP
router.delete("/whitelist/ip/:ip", authenticateToken, async (req: any, res) => {
  try {
    const { ip } = req.params;
    const userId = req.user.userId;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { whitelistedIPs: true },
    });

    if (!user?.whitelistedIPs.includes(ip)) {
      return res.status(404).json({ error: "IP not found in whitelist" });
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        whitelistedIPs: user.whitelistedIPs.filter((i) => i !== ip),
      },
    });

    res.json({
      success: true,
      message: `IP ${ip} removed from whitelist`,
      ips: updatedUser.whitelistedIPs,
    });
  } catch (error) {
    console.error("Remove whitelisted IP error:", error);
    res.status(500).json({ error: "Failed to remove IP from whitelist" });
  }
});

// ============= Wallet Address Whitelist Endpoints =============

// Get user's whitelisted addresses
router.get("/whitelist/addresses", authenticateToken, async (req: any, res) => {
  try {
    const userId = req.user.userId;
    const addresses = await prisma.whitelistedAddress.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    res.json({
      success: true,
      addresses,
    });
  } catch (error) {
    console.error("Get whitelisted addresses error:", error);
    res.status(500).json({ error: "Failed to retrieve whitelisted addresses" });
  }
});

// Add whitelisted wallet address
router.post("/whitelist/address", authenticateToken, async (req: any, res) => {
  try {
    const { address, currency, label } = req.body;
    const userId = req.user.userId;

    if (!address || !currency) {
      return res
        .status(400)
        .json({ error: "Address and currency are required" });
    }

    // Check if address already exists
    const existing = await prisma.whitelistedAddress.findFirst({
      where: {
        userId,
        address,
        currency,
      },
    });

    if (existing) {
      return res.status(400).json({ error: "Address already whitelisted" });
    }

    const whitelisted = await prisma.whitelistedAddress.create({
      data: {
        userId,
        address,
        currency,
        label: label || null,
        verified: false, // Require verification
      },
    });

    // TODO: Send verification email
    // await sendVerificationEmail(userId, whitelisted.id);

    res.json({
      success: true,
      message: "Address added. Verification required before use.",
      address: whitelisted,
    });
  } catch (error) {
    console.error("Add whitelisted address error:", error);
    res.status(500).json({ error: "Failed to add address to whitelist" });
  }
});

// Verify whitelisted address (admin or via email token)
router.post(
  "/whitelist/address/:id/verify",
  authenticateToken,
  async (req: any, res) => {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      const address = await prisma.whitelistedAddress.findFirst({
        where: {
          id,
          userId,
        },
      });

      if (!address) {
        return res.status(404).json({ error: "Address not found" });
      }

      if (address.verified) {
        return res.status(400).json({ error: "Address already verified" });
      }

      const updated = await prisma.whitelistedAddress.update({
        where: { id },
        data: { verified: true },
      });

      res.json({
        success: true,
        message: "Address verified successfully",
        address: updated,
      });
    } catch (error) {
      console.error("Verify address error:", error);
      res.status(500).json({ error: "Failed to verify address" });
    }
  }
);

// Remove whitelisted address
router.delete(
  "/whitelist/address/:id",
  authenticateToken,
  async (req: any, res) => {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      const address = await prisma.whitelistedAddress.findFirst({
        where: {
          id,
          userId,
        },
      });

      if (!address) {
        return res.status(404).json({ error: "Address not found" });
      }

      await prisma.whitelistedAddress.delete({
        where: { id },
      });

      res.json({
        success: true,
        message: "Address removed from whitelist",
      });
    } catch (error) {
      console.error("Remove address error:", error);
      res
        .status(500)
        .json({ error: "Failed to remove address from whitelist" });
    }
  }
);

export default router;
