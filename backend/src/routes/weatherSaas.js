import { Router } from "express";
import axios from "axios";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

// Subscription tier limits and pricing
const TIER_LIMITS = {
  FREE: {
    dailyLimit: 50,
    features: ["current"],
    price: 0,
    name: "Free",
  },
  PRO: {
    dailyLimit: 1000,
    features: ["current", "forecast", "alerts"],
    price: 29.99,
    name: "Pro",
  },
  BUSINESS: {
    dailyLimit: 5000,
    features: ["current", "forecast", "alerts", "historical", "batch"],
    price: 99.99,
    name: "Business",
  },
  ENTERPRISE: {
    dailyLimit: 25000,
    features: [
      "current",
      "forecast",
      "alerts",
      "historical",
      "batch",
      "sla",
      "support",
    ],
    price: 299.99,
    name: "Enterprise",
  },
};

/**
 * @route   GET /api/weather/pricing
 * @desc    Get pricing tiers and features
 * @access  Public
 */
router.get("/pricing", (req, res) => {
  try {
    const pricing = Object.entries(TIER_LIMITS).map(([tier, config]) => ({
      tier,
      name: config.name,
      price: config.price,
      dailyLimit: config.dailyLimit === -1 ? "Unlimited" : config.dailyLimit,
      features: config.features,
    }));

    res.json({
      success: true,
      data: pricing,
    });
  } catch (error) {
    console.error("Pricing error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch pricing information",
    });
  }
});

/**
 * @route   GET /api/weather/usage
 * @desc    Get current user's API usage stats
 * @access  Private
 */
router.get("/usage", requireAuth, async (req, res) => {
  try {
    const userId = req.user?.userId;

    // Mock usage data for now
    const usage = {
      tier: "FREE",
      dailyLimit: 50,
      used: 12,
      remaining: 38,
      resetAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    };

    res.json({
      success: true,
      data: usage,
    });
  } catch (error) {
    console.error("Usage error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch usage information",
    });
  }
});

/**
 * @route   GET /api/weather/current
 * @desc    Get current weather for a city
 * @access  Private
 */
router.get("/current", requireAuth, async (req, res) => {
  try {
    const { city = "London", units = "metric" } = req.query;
    const apiKey = process.env.OPENWEATHERMAP_API_KEY;

    if (!apiKey) {
      return res.status(500).json({
        success: false,
        error: "Weather API key not configured",
      });
    }

    // Call OpenWeatherMap API
    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/weather`,
      {
        params: {
          q: city,
          appid: apiKey,
          units,
        },
      }
    );

    res.json({
      success: true,
      data: {
        city: response.data.name,
        country: response.data.sys.country,
        temperature: response.data.main.temp,
        feelsLike: response.data.main.feels_like,
        humidity: response.data.main.humidity,
        pressure: response.data.main.pressure,
        description: response.data.weather[0].description,
        icon: response.data.weather[0].icon,
        windSpeed: response.data.wind.speed,
        timestamp: new Date(response.data.dt * 1000).toISOString(),
      },
    });
  } catch (error) {
    console.error("Weather API error:", error);
    if (error.response?.status === 404) {
      return res.status(404).json({
        success: false,
        error: "City not found",
      });
    }
    res.status(500).json({
      success: false,
      error: "Failed to fetch weather data",
    });
  }
});

/**
 * @route   GET /api/weather/forecast
 * @desc    Get 5-day weather forecast
 * @access  Private (PRO+)
 */
router.get("/forecast", requireAuth, async (req, res) => {
  try {
    const { city = "London", units = "metric" } = req.query;
    const apiKey = process.env.OPENWEATHERMAP_API_KEY;

    if (!apiKey) {
      return res.status(500).json({
        success: false,
        error: "Weather API key not configured",
      });
    }

    // Call OpenWeatherMap API
    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/forecast`,
      {
        params: {
          q: city,
          appid: apiKey,
          units,
        },
      }
    );

    // Group forecast by day
    const forecast = response.data.list.map((item) => ({
      timestamp: new Date(item.dt * 1000).toISOString(),
      temperature: item.main.temp,
      feelsLike: item.main.feels_like,
      humidity: item.main.humidity,
      description: item.weather[0].description,
      icon: item.weather[0].icon,
      windSpeed: item.wind.speed,
    }));

    res.json({
      success: true,
      data: {
        city: response.data.city.name,
        country: response.data.city.country,
        forecast,
      },
    });
  } catch (error) {
    console.error("Forecast API error:", error);
    if (error.response?.status === 404) {
      return res.status(404).json({
        success: false,
        error: "City not found",
      });
    }
    res.status(500).json({
      success: false,
      error: "Failed to fetch forecast data",
    });
  }
});

/**
 * @route   GET /api/weather/test
 * @desc    Test endpoint to verify API key
 * @access  Public
 */
router.get("/test", async (req, res) => {
  try {
    const apiKey = process.env.OPENWEATHERMAP_API_KEY;

    if (!apiKey) {
      return res.status(500).json({
        success: false,
        error: "OPENWEATHERMAP_API_KEY not configured in .env file",
      });
    }

    // Test API call to London
    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/weather`,
      {
        params: {
          q: "London",
          appid: apiKey,
          units: "metric",
        },
      }
    );

    res.json({
      success: true,
      message: "API key is valid and working!",
      data: {
        apiKeyLength: apiKey.length,
        testCity: response.data.name,
        temperature: response.data.main.temp,
        description: response.data.weather[0].description,
      },
    });
  } catch (error) {
    console.error("API test error:", error);
    if (error.response?.status === 401) {
      return res.status(401).json({
        success: false,
        error:
          "Invalid API key. Please check your OPENWEATHERMAP_API_KEY in .env",
      });
    }
    res.status(500).json({
      success: false,
      error: error.message || "Failed to test API key",
    });
  }
});

export default router;
