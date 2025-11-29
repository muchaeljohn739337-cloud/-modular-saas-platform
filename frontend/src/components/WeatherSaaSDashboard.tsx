'use client';

import { AnimatePresence, motion } from 'framer-motion';
import {
  ArrowRight,
  Check,
  Cloud,
  CloudRain,
  CloudSun,
  Crown,
  Droplets,
  Eye,
  Loader2,
  MapPin,
  RefreshCw,
  Search,
  Sparkles,
  Sun,
  Thermometer,
  Wind,
  X,
  Zap,
} from 'lucide-react';
import { useSession } from 'next-auth/react';
import { useCallback, useEffect, useState } from 'react';

interface WeatherData {
  city: string;
  country: string;
  coordinates: { lat: number; lon: number };
  weather: {
    main: string;
    description: string;
    icon: string;
    iconUrl: string;
  };
  temperature: {
    current: number;
    feelsLike: number;
    min: number;
    max: number;
    units: string;
  };
  details: {
    humidity: number;
    pressure: number;
    visibility: number;
    windSpeed: number;
    windDirection: number;
    clouds: number;
  };
  sun: {
    sunrise: string | null;
    sunset: string | null;
  };
  timestamp: string;
}

interface ForecastDay {
  date: string;
  dayName: string;
  temperature: { min: number; max: number; avg: number; units: string };
  weather: { main: string; description: string; icon: string };
  humidity: number;
  windSpeed: number;
  precipitation: number;
}

interface ForecastData {
  city: string;
  country: string;
  forecast: ForecastDay[];
}

interface UsageData {
  tier: string;
  tierName: string;
  dailyLimit: number;
  callsToday: number;
  remaining: number;
  percentageUsed: number;
  resetsAt: string;
}

interface PricingTier {
  tier: string;
  name: string;
  price: number;
  priceDisplay: string;
  dailyLimit: number;
  features: string[];
}

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

export default function WeatherSaaSDashboard() {
  const { data: session } = useSession();
  const [city, setCity] = useState('');
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [forecast, setForecast] = useState<ForecastData | null>(null);
  const [usage, setUsage] = useState<UsageData | null>(null);
  const [pricing, setPricing] = useState<PricingTier[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPricing, setShowPricing] = useState(false);
  const [units, setUnits] = useState<'metric' | 'imperial'>('metric');

  // Fetch usage stats
  const fetchUsage = useCallback(async () => {
    if (!session?.accessToken) return;
    try {
      const response = await fetch(`${BACKEND_URL}/api/weather/usage`, {
        headers: {
          Authorization: `Bearer ${session.accessToken}`,
        },
      });
      const data = await response.json();
      if (data.success) {
        setUsage(data.data);
      }
    } catch (err) {
      console.error('Failed to fetch usage:', err);
    }
  }, [session?.accessToken]);

  // Fetch pricing
  const fetchPricing = useCallback(async () => {
    try {
      const response = await fetch(`${BACKEND_URL}/api/weather/pricing`);
      const data = await response.json();
      if (data.success) {
        setPricing(data.data);
      }
    } catch (err) {
      console.error('Failed to fetch pricing:', err);
    }
  }, []);

  useEffect(() => {
    fetchPricing();
  }, [fetchPricing]);

  useEffect(() => {
    if (session?.accessToken) {
      fetchUsage();
    }
  }, [session?.accessToken, fetchUsage]);

  // Fetch current weather
  const fetchWeather = async () => {
    if (!city.trim()) {
      setError('Please enter a city name');
      return;
    }
    if (!session?.accessToken) {
      setError('Please sign in to access weather data');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${BACKEND_URL}/api/weather/current?city=${encodeURIComponent(city)}&units=${units}`,
        {
          headers: {
            Authorization: `Bearer ${session.accessToken}`,
          },
        },
      );
      const data = await response.json();

      if (!response.ok) {
        if (response.status === 429) {
          setError(data.message || 'Daily API limit exceeded. Upgrade your plan for more.');
        } else {
          setError(data.message || data.error || 'Failed to fetch weather');
        }
        return;
      }

      setWeather(data.data);
      fetchUsage(); // Refresh usage after successful call
    } catch (err) {
      setError('Failed to connect to weather service');
    } finally {
      setLoading(false);
    }
  };

  // Fetch forecast
  const fetchForecast = async () => {
    if (!city.trim()) {
      setError('Please enter a city name');
      return;
    }
    if (!session?.accessToken) {
      setError('Please sign in to access forecast data');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${BACKEND_URL}/api/weather/forecast?city=${encodeURIComponent(city)}&units=${units}`,
        {
          headers: {
            Authorization: `Bearer ${session.accessToken}`,
          },
        },
      );
      const data = await response.json();

      if (!response.ok) {
        if (response.status === 429) {
          setError(data.message || 'Daily API limit exceeded. Upgrade your plan for more.');
        } else {
          setError(data.message || data.error || 'Failed to fetch forecast');
        }
        return;
      }

      setForecast(data.data);
      fetchUsage(); // Refresh usage after successful call
    } catch (err) {
      setError('Failed to connect to weather service');
    } finally {
      setLoading(false);
    }
  };

  const getWeatherIcon = (main: string) => {
    switch (main?.toLowerCase()) {
      case 'clear':
        return <Sun className="h-12 w-12 text-yellow-500" />;
      case 'clouds':
        return <Cloud className="h-12 w-12 text-gray-400" />;
      case 'rain':
      case 'drizzle':
        return <CloudRain className="h-12 w-12 text-blue-400" />;
      default:
        return <CloudSun className="h-12 w-12 text-blue-300" />;
    }
  };

  const getTierIcon = (tier: string) => {
    switch (tier) {
      case 'ENTERPRISE':
        return <Crown className="h-6 w-6 text-purple-500" />;
      case 'BUSINESS':
        return <Sparkles className="h-6 w-6 text-blue-500" />;
      case 'PRO':
        return <Zap className="h-6 w-6 text-orange-500" />;
      default:
        return <Cloud className="h-6 w-6 text-gray-400" />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 p-4 md:p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        {/* Header */}
        <div className="text-center space-y-4">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="inline-flex items-center gap-3 bg-white px-6 py-3 rounded-2xl shadow-lg border"
          >
            <Cloud className="h-8 w-8 text-blue-500" />
            <h1 className="text-2xl md:text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Weather API SaaS
            </h1>
          </motion.div>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Get real-time weather data and forecasts. Start free with 50 API calls/day or upgrade for
            more.
          </p>
        </div>

        {/* Usage Stats Card */}
        {session && usage && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-lg border p-6"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                {getTierIcon(usage.tier)}
                <div>
                  <h3 className="font-semibold text-lg">{usage.tierName} Plan</h3>
                  <p className="text-sm text-gray-500">
                    {usage.callsToday} / {usage.dailyLimit} calls today
                  </p>
                </div>
              </div>
              <button
                onClick={() => setShowPricing(true)}
                className="px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg hover:opacity-90 transition-opacity flex items-center gap-2"
              >
                Upgrade <ArrowRight className="h-4 w-4" />
              </button>
            </div>
            <div className="relative h-3 bg-gray-200 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${usage.percentageUsed}%` }}
                transition={{ duration: 0.5 }}
                className={`absolute h-full rounded-full ${
                  usage.percentageUsed > 80
                    ? 'bg-red-500'
                    : usage.percentageUsed > 50
                      ? 'bg-yellow-500'
                      : 'bg-green-500'
                }`}
              />
            </div>
            <p className="text-xs text-gray-500 mt-2">
              {usage.remaining} calls remaining • Resets at midnight UTC
            </p>
          </motion.div>
        )}

        {/* Search Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl shadow-lg border p-6"
        >
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1 relative">
              <MapPin className="absolute left-4 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={city}
                onChange={(e) => setCity(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && fetchWeather()}
                placeholder="Enter city name..."
                className="w-full pl-12 pr-4 py-3 border rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
              />
            </div>
            <div className="flex gap-2">
              <select
                value={units}
                onChange={(e) => setUnits(e.target.value as 'metric' | 'imperial')}
                className="px-4 py-3 border rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none bg-white"
              >
                <option value="metric">°C</option>
                <option value="imperial">°F</option>
              </select>
              <button
                onClick={fetchWeather}
                disabled={loading}
                className="px-6 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors flex items-center gap-2 disabled:opacity-50"
              >
                {loading ? (
                  <Loader2 className="h-5 w-5 animate-spin" />
                ) : (
                  <Search className="h-5 w-5" />
                )}
                Current
              </button>
              <button
                onClick={fetchForecast}
                disabled={loading}
                className="px-6 py-3 bg-purple-600 text-white rounded-xl hover:bg-purple-700 transition-colors flex items-center gap-2 disabled:opacity-50"
              >
                {loading ? (
                  <Loader2 className="h-5 w-5 animate-spin" />
                ) : (
                  <RefreshCw className="h-5 w-5" />
                )}
                5-Day
              </button>
            </div>
          </div>

          {error && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="mt-4 p-4 bg-red-50 border border-red-200 rounded-xl text-red-600 flex items-center gap-2"
            >
              <X className="h-5 w-5 flex-shrink-0" />
              {error}
            </motion.div>
          )}
        </motion.div>

        {/* Current Weather Display */}
        {weather && (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-xl p-8 text-white"
          >
            <div className="flex flex-col md:flex-row items-center justify-between gap-6">
              <div className="text-center md:text-left">
                <h2 className="text-3xl font-bold">
                  {weather.city}, {weather.country}
                </h2>
                <p className="text-blue-100 capitalize mt-1">{weather.weather.description}</p>
                <div className="flex items-center gap-4 mt-4">
                  <span className="text-6xl font-bold">
                    {Math.round(weather.temperature.current)}
                    {weather.temperature.units}
                  </span>
                  {weather.weather.iconUrl && (
                    <img
                      src={weather.weather.iconUrl}
                      alt={weather.weather.description}
                      className="h-20 w-20"
                    />
                  )}
                </div>
                <p className="text-blue-100 mt-2">
                  Feels like {Math.round(weather.temperature.feelsLike)}
                  {weather.temperature.units}
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="bg-white/20 backdrop-blur rounded-xl p-4">
                  <div className="flex items-center gap-2">
                    <Droplets className="h-5 w-5" />
                    <span className="text-sm">Humidity</span>
                  </div>
                  <span className="text-2xl font-bold">{weather.details.humidity}%</span>
                </div>
                <div className="bg-white/20 backdrop-blur rounded-xl p-4">
                  <div className="flex items-center gap-2">
                    <Wind className="h-5 w-5" />
                    <span className="text-sm">Wind</span>
                  </div>
                  <span className="text-2xl font-bold">
                    {weather.details.windSpeed} {units === 'imperial' ? 'mph' : 'm/s'}
                  </span>
                </div>
                <div className="bg-white/20 backdrop-blur rounded-xl p-4">
                  <div className="flex items-center gap-2">
                    <Eye className="h-5 w-5" />
                    <span className="text-sm">Visibility</span>
                  </div>
                  <span className="text-2xl font-bold">
                    {Math.round(weather.details.visibility / 1000)} km
                  </span>
                </div>
                <div className="bg-white/20 backdrop-blur rounded-xl p-4">
                  <div className="flex items-center gap-2">
                    <Thermometer className="h-5 w-5" />
                    <span className="text-sm">Pressure</span>
                  </div>
                  <span className="text-2xl font-bold">{weather.details.pressure} hPa</span>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* 5-Day Forecast Display */}
        {forecast && forecast.forecast && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-lg border p-6"
          >
            <h3 className="text-xl font-bold mb-6">
              5-Day Forecast for {forecast.city}, {forecast.country}
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
              {forecast.forecast.map((day, index) => (
                <motion.div
                  key={day.date}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-xl p-4 text-center"
                >
                  <p className="font-semibold text-gray-700">{day.dayName}</p>
                  <p className="text-xs text-gray-500">{day.date}</p>
                  <div className="my-4 flex justify-center">
                    {getWeatherIcon(day.weather.main)}
                  </div>
                  <p className="text-sm capitalize text-gray-600">{day.weather.description}</p>
                  <div className="mt-3 space-y-1">
                    <p className="text-lg font-bold text-blue-600">
                      {Math.round(day.temperature.max)}° / {Math.round(day.temperature.min)}°
                    </p>
                    <p className="text-xs text-gray-500">
                      <Droplets className="inline h-3 w-3 mr-1" />
                      {day.humidity}%
                    </p>
                    <p className="text-xs text-gray-500">
                      <Wind className="inline h-3 w-3 mr-1" />
                      {day.windSpeed} {units === 'imperial' ? 'mph' : 'm/s'}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Pricing Section */}
        {!session && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-lg border p-8 text-center"
          >
            <h3 className="text-2xl font-bold mb-4">Sign in to Access Weather Data</h3>
            <p className="text-gray-600 mb-6">
              Create a free account to get started with 50 API calls per day.
            </p>
            <a
              href="/auth/signin"
              className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl hover:opacity-90 transition-opacity"
            >
              Get Started Free <ArrowRight className="h-5 w-5" />
            </a>
          </motion.div>
        )}

        {/* Pricing Modal */}
        <AnimatePresence>
          {showPricing && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
              onClick={() => setShowPricing(false)}
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.9, opacity: 0 }}
                className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-y-auto p-8"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-2xl font-bold">Choose Your Plan</h2>
                  <button
                    onClick={() => setShowPricing(false)}
                    className="p-2 hover:bg-gray-100 rounded-xl transition-colors"
                  >
                    <X className="h-6 w-6" />
                  </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                  {pricing.map((tier, index) => (
                    <motion.div
                      key={tier.tier}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className={`rounded-2xl border-2 p-6 ${
                        tier.tier === 'PRO'
                          ? 'border-blue-500 shadow-lg relative'
                          : 'border-gray-200'
                      }`}
                    >
                      {tier.tier === 'PRO' && (
                        <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                          <span className="bg-blue-500 text-white text-xs font-bold px-3 py-1 rounded-full">
                            POPULAR
                          </span>
                        </div>
                      )}
                      <div className="flex items-center gap-2 mb-4">
                        {getTierIcon(tier.tier)}
                        <h3 className="text-xl font-bold">{tier.name}</h3>
                      </div>
                      <div className="mb-4">
                        <span className="text-3xl font-bold">{tier.priceDisplay}</span>
                      </div>
                      <p className="text-gray-600 mb-4">
                        {tier.dailyLimit.toLocaleString()} API calls/day
                      </p>
                      <ul className="space-y-2 mb-6">
                        {tier.features.map((feature, i) => (
                          <li key={i} className="flex items-center gap-2 text-sm text-gray-600">
                            <Check className="h-4 w-4 text-green-500 flex-shrink-0" />
                            {feature}
                          </li>
                        ))}
                      </ul>
                      <button
                        className={`w-full py-3 rounded-xl font-semibold transition-colors ${
                          usage?.tier === tier.tier
                            ? 'bg-gray-200 text-gray-500 cursor-not-allowed'
                            : tier.tier === 'PRO'
                              ? 'bg-blue-600 text-white hover:bg-blue-700'
                              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }`}
                        disabled={usage?.tier === tier.tier}
                      >
                        {usage?.tier === tier.tier ? 'Current Plan' : 'Select Plan'}
                      </button>
                    </motion.div>
                  ))}
                </div>

                <div className="mt-8 text-center text-gray-500 text-sm">
                  <p>All plans include API documentation and email support.</p>
                  <p className="mt-1">Enterprise customers receive dedicated account management.</p>
                </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
