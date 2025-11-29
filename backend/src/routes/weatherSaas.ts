import { Request, Response, Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import prisma from '../prismaClient';

const router = Router();

// OpenWeatherMap API configuration
const OPENWEATHERMAP_API_KEY = process.env.OPENWEATHERMAP_API_KEY || '';
const OPENWEATHERMAP_BASE_URL = 'https://api.openweathermap.org/data/2.5';

// Subscription tier configurations
const SUBSCRIPTION_TIERS = {
  FREE: { price: 0, dailyLimit: 50, name: 'Free' },
  PRO: { price: 29.99, dailyLimit: 1000, name: 'Pro' },
  BUSINESS: { price: 99.99, dailyLimit: 5000, name: 'Business' },
  ENTERPRISE: { price: 299.99, dailyLimit: 25000, name: 'Enterprise' },
};

type SubscriptionTierKey = keyof typeof SUBSCRIPTION_TIERS;

// OpenWeatherMap API response interfaces
interface OpenWeatherCurrentResponse {
  name: string;
  sys?: { country?: string; sunrise?: number; sunset?: number };
  coord?: { lat: number; lon: number };
  weather?: Array<{ main: string; description: string; icon: string }>;
  main?: {
    temp: number;
    feels_like: number;
    temp_min: number;
    temp_max: number;
    humidity: number;
    pressure: number;
  };
  wind?: { speed: number; deg: number };
  visibility?: number;
  clouds?: { all: number };
}

interface OpenWeatherForecastResponse {
  city?: {
    name: string;
    country: string;
    coord?: { lat: number; lon: number };
    timezone: number;
  };
  list: Array<{
    dt: number;
    main: { temp: number; temp_min: number; temp_max: number; humidity: number };
    weather: Array<{ main: string; description: string; icon: string }>;
    wind: { speed: number };
    pop: number;
  }>;
}

interface OpenWeatherErrorResponse {
  message?: string;
}

/**
 * GET /api/weather/test
 * Test endpoint to validate OpenWeatherMap API key
 */
router.get('/test', async (req: Request, res: Response) => {
  try {
    if (!OPENWEATHERMAP_API_KEY) {
      return res.status(500).json({
        success: false,
        error: 'OpenWeatherMap API key not configured',
        message: 'Please set OPENWEATHERMAP_API_KEY in environment variables',
      });
    }

    // Test the API key with a simple weather request for London
    const testCity = 'London';
    const response = await fetch(
      `${OPENWEATHERMAP_BASE_URL}/weather?q=${testCity}&appid=${OPENWEATHERMAP_API_KEY}&units=metric`,
    );

    if (!response.ok) {
      const errorData = (await response.json()) as OpenWeatherErrorResponse;
      return res.status(response.status).json({
        success: false,
        error: 'API key validation failed',
        message: errorData.message || 'Invalid API key',
      });
    }

    const data = (await response.json()) as OpenWeatherCurrentResponse;

    return res.json({
      success: true,
      message: 'API key is valid and working!',
      data: {
        apiKeyLength: OPENWEATHERMAP_API_KEY.length,
        testCity,
        temperature: data.main?.temp,
        description: data.weather?.[0]?.description,
      },
    });
  } catch (error) {
    console.error('[Weather API] Test endpoint error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to validate API key',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /api/weather/pricing
 * Returns available subscription tiers and pricing
 */
router.get('/pricing', async (req: Request, res: Response) => {
  try {
    const tiers = Object.entries(SUBSCRIPTION_TIERS).map(([tier, config]) => ({
      tier,
      name: config.name,
      price: config.price,
      priceDisplay: config.price === 0 ? 'Free' : `$${config.price}/mo`,
      dailyLimit: config.dailyLimit,
      features: getPricingFeatures(tier as SubscriptionTierKey),
    }));

    return res.json({
      success: true,
      data: tiers,
    });
  } catch (error) {
    console.error('[Weather API] Pricing endpoint error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch pricing information',
    });
  }
});

/**
 * GET /api/weather/usage
 * Returns user's API usage statistics (requires authentication)
 */
router.get('/usage', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        weatherSubscriptionTier: true,
        weatherApiCallsToday: true,
        weatherLastApiCall: true,
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const tier = (user.weatherSubscriptionTier || 'FREE') as SubscriptionTierKey;
    const tierConfig = SUBSCRIPTION_TIERS[tier];
    const callsToday = user.weatherApiCallsToday || 0;
    const remaining = Math.max(0, tierConfig.dailyLimit - callsToday);
    const percentageUsed = Math.round((callsToday / tierConfig.dailyLimit) * 100);

    return res.json({
      success: true,
      data: {
        tier,
        tierName: tierConfig.name,
        dailyLimit: tierConfig.dailyLimit,
        callsToday,
        remaining,
        percentageUsed,
        lastApiCall: user.weatherLastApiCall,
        resetsAt: getResetTime(),
      },
    });
  } catch (error) {
    console.error('[Weather API] Usage endpoint error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch usage information',
    });
  }
});

/**
 * GET /api/weather/current
 * Returns current weather for a city (requires authentication)
 */
router.get('/current', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
    }

    const { city, lat, lon, units = 'metric' } = req.query;

    if (!city && (!lat || !lon)) {
      return res.status(400).json({
        success: false,
        error: 'City name or coordinates (lat, lon) are required',
      });
    }

    // Check rate limit
    const rateLimitCheck = await checkAndUpdateRateLimit(userId);
    if (!rateLimitCheck.allowed) {
      return res.status(429).json({
        success: false,
        error: 'Daily API limit exceeded',
        message: `You have reached your daily limit of ${rateLimitCheck.limit} calls. Upgrade your plan for more.`,
        usage: rateLimitCheck,
      });
    }

    if (!OPENWEATHERMAP_API_KEY) {
      return res.status(500).json({
        success: false,
        error: 'Weather API not configured',
      });
    }

    // Build API URL
    let url: string;
    if (city) {
      url = `${OPENWEATHERMAP_BASE_URL}/weather?q=${encodeURIComponent(
        city as string,
      )}&appid=${OPENWEATHERMAP_API_KEY}&units=${units}`;
    } else {
      url = `${OPENWEATHERMAP_BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${OPENWEATHERMAP_API_KEY}&units=${units}`;
    }

    const response = await fetch(url);
    const data = (await response.json()) as OpenWeatherCurrentResponse | OpenWeatherErrorResponse;

    if (!response.ok) {
      return res.status(response.status).json({
        success: false,
        error: 'Weather API error',
        message: (data as OpenWeatherErrorResponse).message || 'Failed to fetch weather data',
      });
    }

    const weatherData = data as OpenWeatherCurrentResponse;

    return res.json({
      success: true,
      data: {
        city: weatherData.name,
        country: weatherData.sys?.country,
        coordinates: {
          lat: weatherData.coord?.lat,
          lon: weatherData.coord?.lon,
        },
        weather: {
          main: weatherData.weather?.[0]?.main,
          description: weatherData.weather?.[0]?.description,
          icon: weatherData.weather?.[0]?.icon,
          iconUrl: `https://openweathermap.org/img/wn/${weatherData.weather?.[0]?.icon}@2x.png`,
        },
        temperature: {
          current: weatherData.main?.temp,
          feelsLike: weatherData.main?.feels_like,
          min: weatherData.main?.temp_min,
          max: weatherData.main?.temp_max,
          units: units === 'imperial' ? '°F' : '°C',
        },
        details: {
          humidity: weatherData.main?.humidity,
          pressure: weatherData.main?.pressure,
          visibility: weatherData.visibility,
          windSpeed: weatherData.wind?.speed,
          windDirection: weatherData.wind?.deg,
          clouds: weatherData.clouds?.all,
        },
        sun: {
          sunrise: weatherData.sys?.sunrise
            ? new Date(weatherData.sys.sunrise * 1000).toISOString()
            : null,
          sunset: weatherData.sys?.sunset
            ? new Date(weatherData.sys.sunset * 1000).toISOString()
            : null,
        },
        timestamp: new Date().toISOString(),
      },
      usage: {
        callsToday: rateLimitCheck.callsToday,
        remaining: rateLimitCheck.remaining,
        limit: rateLimitCheck.limit,
      },
    });
  } catch (error) {
    console.error('[Weather API] Current weather error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch weather data',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /api/weather/forecast
 * Returns 5-day forecast for a city (requires authentication)
 */
router.get('/forecast', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
    }

    const { city, lat, lon, units = 'metric' } = req.query;

    if (!city && (!lat || !lon)) {
      return res.status(400).json({
        success: false,
        error: 'City name or coordinates (lat, lon) are required',
      });
    }

    // Check rate limit
    const rateLimitCheck = await checkAndUpdateRateLimit(userId);
    if (!rateLimitCheck.allowed) {
      return res.status(429).json({
        success: false,
        error: 'Daily API limit exceeded',
        message: `You have reached your daily limit of ${rateLimitCheck.limit} calls. Upgrade your plan for more.`,
        usage: rateLimitCheck,
      });
    }

    if (!OPENWEATHERMAP_API_KEY) {
      return res.status(500).json({
        success: false,
        error: 'Weather API not configured',
      });
    }

    // Build API URL for 5-day forecast
    let url: string;
    if (city) {
      url = `${OPENWEATHERMAP_BASE_URL}/forecast?q=${encodeURIComponent(
        city as string,
      )}&appid=${OPENWEATHERMAP_API_KEY}&units=${units}`;
    } else {
      url = `${OPENWEATHERMAP_BASE_URL}/forecast?lat=${lat}&lon=${lon}&appid=${OPENWEATHERMAP_API_KEY}&units=${units}`;
    }

    const response = await fetch(url);
    const data = (await response.json()) as OpenWeatherForecastResponse | OpenWeatherErrorResponse;

    if (!response.ok) {
      return res.status(response.status).json({
        success: false,
        error: 'Weather API error',
        message: (data as OpenWeatherErrorResponse).message || 'Failed to fetch forecast data',
      });
    }

    const forecastData = data as OpenWeatherForecastResponse;

    // Process forecast data into daily summaries
    const dailyForecasts = processForecastData(forecastData.list, units as string);

    return res.json({
      success: true,
      data: {
        city: forecastData.city?.name,
        country: forecastData.city?.country,
        coordinates: {
          lat: forecastData.city?.coord?.lat,
          lon: forecastData.city?.coord?.lon,
        },
        timezone: forecastData.city?.timezone,
        forecast: dailyForecasts,
        timestamp: new Date().toISOString(),
      },
      usage: {
        callsToday: rateLimitCheck.callsToday,
        remaining: rateLimitCheck.remaining,
        limit: rateLimitCheck.limit,
      },
    });
  } catch (error) {
    console.error('[Weather API] Forecast error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch forecast data',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Helper Functions

/**
 * Get features for each pricing tier
 */
function getPricingFeatures(tier: SubscriptionTierKey): string[] {
  const baseFeatures = ['Current weather data', 'City search'];
  
  switch (tier) {
    case 'FREE':
      return [...baseFeatures, '50 API calls/day'];
    case 'PRO':
      return [
        ...baseFeatures,
        '1,000 API calls/day',
        '5-day forecast',
        'Priority support',
      ];
    case 'BUSINESS':
      return [
        ...baseFeatures,
        '5,000 API calls/day',
        '5-day forecast',
        'Historical data',
        'Priority support',
        'API analytics',
      ];
    case 'ENTERPRISE':
      return [
        ...baseFeatures,
        '25,000 API calls/day',
        '5-day forecast',
        'Historical data',
        'Premium support',
        'API analytics',
        'Custom integrations',
        'Dedicated account manager',
      ];
    default:
      return baseFeatures;
  }
}

/**
 * Get the time when daily limits reset (midnight UTC)
 */
function getResetTime(): string {
  const now = new Date();
  const tomorrow = new Date(now);
  tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
  tomorrow.setUTCHours(0, 0, 0, 0);
  return tomorrow.toISOString();
}

/**
 * Check and update rate limit for a user
 */
async function checkAndUpdateRateLimit(userId: string): Promise<{
  allowed: boolean;
  callsToday: number;
  remaining: number;
  limit: number;
}> {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        weatherSubscriptionTier: true,
        weatherApiCallsToday: true,
        weatherLastApiCall: true,
      },
    });

    if (!user) {
      return { allowed: false, callsToday: 0, remaining: 0, limit: 0 };
    }

    const tier = (user.weatherSubscriptionTier || 'FREE') as SubscriptionTierKey;
    const tierConfig = SUBSCRIPTION_TIERS[tier];
    let callsToday = user.weatherApiCallsToday || 0;

    // Reset counter if last call was on a different day (UTC)
    const lastCall = user.weatherLastApiCall;
    const now = new Date();
    if (lastCall) {
      const lastCallDate = new Date(lastCall);
      if (
        lastCallDate.getUTCDate() !== now.getUTCDate() ||
        lastCallDate.getUTCMonth() !== now.getUTCMonth() ||
        lastCallDate.getUTCFullYear() !== now.getUTCFullYear()
      ) {
        callsToday = 0;
      }
    }

    // Check if limit exceeded
    if (callsToday >= tierConfig.dailyLimit) {
      return {
        allowed: false,
        callsToday,
        remaining: 0,
        limit: tierConfig.dailyLimit,
      };
    }

    // Update counter
    await prisma.user.update({
      where: { id: userId },
      data: {
        weatherApiCallsToday: callsToday + 1,
        weatherLastApiCall: now,
      },
    });

    return {
      allowed: true,
      callsToday: callsToday + 1,
      remaining: tierConfig.dailyLimit - callsToday - 1,
      limit: tierConfig.dailyLimit,
    };
  } catch (error) {
    console.error('[Weather API] Rate limit check error:', error);
    // Allow the request if rate limiting fails to avoid blocking users
    return { allowed: true, callsToday: 0, remaining: 50, limit: 50 };
  }
}

/**
 * Process raw forecast data into daily summaries
 */
function processForecastData(
  list: Array<{
    dt: number;
    main: { temp: number; temp_min: number; temp_max: number; humidity: number };
    weather: Array<{ main: string; description: string; icon: string }>;
    wind: { speed: number };
    pop: number;
  }>,
  units: string,
): Array<{
  date: string;
  dayName: string;
  temperature: { min: number; max: number; avg: number; units: string };
  weather: { main: string; description: string; icon: string };
  humidity: number;
  windSpeed: number;
  precipitation: number;
}> {
  const dailyData: Record<
    string,
    {
      temps: number[];
      tempMins: number[];
      tempMaxs: number[];
      humidity: number[];
      windSpeed: number[];
      pop: number[];
      weather: Array<{ main: string; description: string; icon: string }>;
    }
  > = {};

  // Group data by date
  for (const item of list) {
    const dateStr = new Date(item.dt * 1000).toISOString().split('T')[0] || '';
    if (!dateStr) continue;
    if (!dailyData[dateStr]) {
      dailyData[dateStr] = {
        temps: [],
        tempMins: [],
        tempMaxs: [],
        humidity: [],
        windSpeed: [],
        pop: [],
        weather: [],
      };
    }
    const dayData = dailyData[dateStr];
    dayData.temps.push(item.main.temp);
    dayData.tempMins.push(item.main.temp_min);
    dayData.tempMaxs.push(item.main.temp_max);
    dayData.humidity.push(item.main.humidity);
    dayData.windSpeed.push(item.wind.speed);
    dayData.pop.push(item.pop || 0);
    if (item.weather?.[0]) {
      dayData.weather.push(item.weather[0]);
    }
  }

  // Convert to daily summaries
  const dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ] as const;

  return Object.entries(dailyData)
    .slice(0, 5) // Only 5 days
    .map(([date, data]) => {
      const dayDate = new Date(date);
      const dayIndex = dayDate.getDay();
      const avgTemp =
        data.temps.reduce((a, b) => a + b, 0) / data.temps.length;
      const minTemp = Math.min(...data.tempMins);
      const maxTemp = Math.max(...data.tempMaxs);
      const avgHumidity = Math.round(
        data.humidity.reduce((a, b) => a + b, 0) / data.humidity.length,
      );
      const avgWindSpeed =
        data.windSpeed.reduce((a, b) => a + b, 0) / data.windSpeed.length;
      const maxPop = Math.max(...data.pop);

      // Get most common weather condition
      const weatherCounts = data.weather.reduce(
        (acc, w) => {
          acc[w.main] = (acc[w.main] || 0) + 1;
          return acc;
        },
        {} as Record<string, number>,
      );
      const sortedWeatherCounts = Object.entries(weatherCounts).sort(
        (a, b) => b[1] - a[1],
      );
      const firstWeatherEntry = sortedWeatherCounts[0];
      const dominantWeatherMain = firstWeatherEntry ? firstWeatherEntry[0] : null;
      const weatherItem =
        data.weather.find((w) => w.main === dominantWeatherMain) ||
        data.weather[0];

      return {
        date,
        dayName: dayNames[dayIndex] || 'Unknown',
        temperature: {
          min: Math.round(minTemp * 10) / 10,
          max: Math.round(maxTemp * 10) / 10,
          avg: Math.round(avgTemp * 10) / 10,
          units: units === 'imperial' ? '°F' : '°C',
        },
        weather: {
          main: weatherItem?.main || 'Unknown',
          description: weatherItem?.description || 'No data',
          icon: weatherItem?.icon || '01d',
        },
        humidity: avgHumidity,
        windSpeed: Math.round(avgWindSpeed * 10) / 10,
        precipitation: Math.round(maxPop * 100),
      };
    });
}

export default router;
