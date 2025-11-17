"use client";

import React, { useState, useEffect } from "react";
import {
  Search,
  Wind,
  Droplets,
  Eye,
  Gauge,
  Cloud,
  Crown,
  TrendingUp,
  Bell,
  Zap,
} from "lucide-react";

interface WeatherData {
  city: string;
  country: string;
  temperature: number;
  feelsLike: number;
  tempMin: number;
  tempMax: number;
  humidity: number;
  pressure: number;
  description: string;
  icon: string;
  windSpeed: number;
  windDeg: number;
  clouds: number;
  visibility: number;
  units: string;
  timestamp: string;
}

interface UsageData {
  currentTier: string;
  tierName: string;
  callsUsed: number;
  callsLimit: string | number;
  resetAt: string;
  last30Days: number;
  avgResponseTime: number;
  features: string[];
}

interface PricingTier {
  tier: string;
  name: string;
  price: number;
  dailyLimit: string | number;
  features: string[];
  description: string;
}

const WeatherSaaSDashboard: React.FC = () => {
  const [city, setCity] = useState("");
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [usage, setUsage] = useState<UsageData | null>(null);
  const [pricing, setPricing] = useState<PricingTier[]>([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [units, setUnits] = useState<"metric" | "imperial">("metric");
  const [showPricing, setShowPricing] = useState(false);
  const [meta, setMeta] = useState<any>(null);

  useEffect(() => {
    fetchUsage();
    fetchPricing();
  }, []);

  const fetchUsage = async () => {
    try {
      const token = localStorage.getItem("authToken");
      const res = await fetch("/api/weather/usage", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      if (data.success) setUsage(data.data);
    } catch (e) {
      console.error("Failed to fetch usage", e);
    }
  };

  const fetchPricing = async () => {
    try {
      const res = await fetch("/api/weather/pricing");
      const data = await res.json();
      if (data.success) setPricing(data.tiers);
    } catch (e) {
      console.error("Failed to fetch pricing", e);
    }
  };

  const fetchWeather = async () => {
    if (!city.trim()) {
      setError("Please enter a city name");
      return;
    }

    setError("");
    setLoading(true);
    setWeather(null);

    try {
      const token = localStorage.getItem("authToken");
      const res = await fetch(
        `/api/weather?city=${encodeURIComponent(city)}&units=${units}`,
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      const data = await res.json();

      if (!data.success) {
        if (res.status === 429) {
          setShowPricing(true);
        }
        throw new Error(data.error || "Failed to fetch weather");
      }

      setWeather(data.data);
      setMeta(data.meta);
      fetchUsage(); // Refresh usage stats
    } catch (e: any) {
      setError(e.message || "An error occurred");
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") fetchWeather();
  };

  const toggleUnits = () => {
    setUnits((prev) => (prev === "metric" ? "imperial" : "metric"));
  };

  const getTempUnit = () => (units === "metric" ? "°C" : "°F");

  const getTierBadgeColor = (tier: string) => {
    const colors: Record<string, string> = {
      FREE: "bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-300",
      PRO: "bg-blue-200 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
      BUSINESS:
        "bg-purple-200 text-purple-800 dark:bg-purple-900 dark:text-purple-300",
      ENTERPRISE:
        "bg-yellow-200 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
    };
    return colors[tier] || colors.FREE;
  };

  const getProgressColor = (percentage: number) => {
    if (percentage < 50) return "bg-green-500";
    if (percentage < 80) return "bg-yellow-500";
    return "bg-red-500";
  };

  const usagePercentage =
    usage && typeof usage.callsLimit === "number"
      ? (usage.callsUsed / usage.callsLimit) * 100
      : 0;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800 p-4 md:p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header with Usage Stats */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
          {/* Main Header */}
          <div className="lg:col-span-2 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-2xl shadow-2xl p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h1 className="text-3xl md:text-4xl font-bold mb-2">
                  Weather API SaaS
                </h1>
                <p className="text-blue-100">
                  Professional weather data for your applications
                </p>
              </div>
              {usage && (
                <span
                  className={`px-4 py-2 rounded-full text-sm font-bold ${getTierBadgeColor(
                    usage.currentTier
                  )}`}
                >
                  {usage.tierName}
                </span>
              )}
            </div>

            {usage && (
              <div className="mt-4">
                <div className="flex justify-between text-sm mb-2">
                  <span>API Calls Today</span>
                  <span className="font-bold">
                    {usage.callsUsed} /{" "}
                    {usage.callsLimit === "Unlimited" ? "∞" : usage.callsLimit}
                  </span>
                </div>
                {usage.callsLimit !== "Unlimited" && (
                  <div className="w-full bg-white/20 rounded-full h-2">
                    <div
                      className={`h-2 rounded-full transition-all duration-300 ${getProgressColor(
                        usagePercentage
                      )}`}
                      style={{ width: `${Math.min(usagePercentage, 100)}%` }}
                    />
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Quick Stats */}
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6">
            <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-blue-600" />
              30-Day Stats
            </h3>
            {usage ? (
              <div className="space-y-3">
                <div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {usage.last30Days}
                  </div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    Total Requests
                  </div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {usage.avgResponseTime}ms
                  </div>
                  <div className="text-sm text-gray-600 dark:text-gray-400">
                    Avg Response Time
                  </div>
                </div>
                <button
                  onClick={() => setShowPricing(!showPricing)}
                  className="w-full mt-2 px-4 py-2 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-lg font-semibold hover:from-blue-700 hover:to-indigo-700 transition-all flex items-center justify-center gap-2"
                >
                  <Crown className="w-4 h-4" />
                  {usage.currentTier === "FREE" ? "Upgrade Plan" : "View Plans"}
                </button>
              </div>
            ) : (
              <div className="text-gray-600 dark:text-gray-400">
                Loading stats...
              </div>
            )}
          </div>
        </div>

        {/* Pricing Modal */}
        {showPricing && (
          <div className="mb-6 bg-white dark:bg-gray-800 rounded-2xl shadow-2xl overflow-hidden">
            <div className="bg-gradient-to-r from-blue-600 to-indigo-600 p-6 text-white">
              <div className="flex justify-between items-center">
                <h2 className="text-2xl font-bold">Subscription Plans</h2>
                <button
                  onClick={() => setShowPricing(false)}
                  className="text-white hover:text-gray-200 text-2xl"
                >
                  ×
                </button>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 p-6">
              {pricing.map((tier) => (
                <div
                  key={tier.tier}
                  className={`border-2 rounded-xl p-6 transition-all hover:shadow-xl ${
                    usage?.currentTier === tier.tier
                      ? "border-blue-600 bg-blue-50 dark:bg-blue-900/20"
                      : "border-gray-200 dark:border-gray-700 hover:border-blue-400"
                  }`}
                >
                  <div className="text-center mb-4">
                    <h3 className="text-xl font-bold text-gray-900 dark:text-white">
                      {tier.name}
                    </h3>
                    <div className="mt-2">
                      <span className="text-3xl font-bold text-gray-900 dark:text-white">
                        ${tier.price}
                      </span>
                      <span className="text-gray-600 dark:text-gray-400">
                        /month
                      </span>
                    </div>
                    <div className="text-sm text-gray-600 dark:text-gray-400 mt-2">
                      {tier.dailyLimit === "Unlimited"
                        ? "Unlimited"
                        : `${tier.dailyLimit}`}{" "}
                      calls/day
                    </div>
                  </div>
                  <ul className="space-y-2 mb-6">
                    {tier.features.map((feature) => (
                      <li
                        key={feature}
                        className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300"
                      >
                        <Zap className="w-4 h-4 text-blue-600" />
                        {feature}
                      </li>
                    ))}
                  </ul>
                  {usage?.currentTier === tier.tier ? (
                    <button
                      disabled
                      className="w-full py-2 bg-gray-300 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded-lg font-semibold cursor-not-allowed"
                    >
                      Current Plan
                    </button>
                  ) : (
                    <button className="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition-colors">
                      Upgrade
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Search */}
        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl overflow-hidden mb-6">
          <div className="p-6 md:p-8 border-b border-gray-200 dark:border-gray-700">
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1 relative">
                <input
                  type="text"
                  placeholder="Enter city name..."
                  value={city}
                  onChange={(e) => setCity(e.target.value)}
                  onKeyPress={handleKeyPress}
                  className="w-full px-4 py-3 pl-12 rounded-lg border border-gray-300 dark:border-gray-600 
                           bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                           focus:ring-2 focus:ring-blue-500 focus:border-transparent
                           transition-all duration-200"
                  disabled={loading}
                />
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              </div>

              <button
                onClick={fetchWeather}
                disabled={loading}
                className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold 
                         rounded-lg transition-colors duration-200 disabled:opacity-50
                         disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
              >
                {loading ? "Searching..." : "Get Weather"}
              </button>

              <button
                onClick={toggleUnits}
                className="px-6 py-3 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 
                         dark:hover:bg-gray-600 text-gray-800 dark:text-white font-semibold 
                         rounded-lg transition-colors duration-200"
              >
                {units === "metric" ? "°C" : "°F"}
              </button>
            </div>

            {meta && (
              <div className="mt-4 text-sm text-gray-600 dark:text-gray-400 flex items-center gap-2">
                <Zap className="w-4 h-4" />
                API Calls Remaining: {meta.callsRemaining}
              </div>
            )}
          </div>

          {/* Error Message */}
          {error && (
            <div
              className="mx-6 mt-6 p-4 bg-red-100 dark:bg-red-900/30 border border-red-400 
                          dark:border-red-700 text-red-700 dark:text-red-300 rounded-lg"
            >
              {error}
            </div>
          )}

          {/* Weather Display */}
          {weather && (
            <div className="p-6 md:p-8">
              <div className="text-center mb-8">
                <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-2">
                  {weather.city}, {weather.country}
                </h2>
                <div className="flex items-center justify-center gap-4 mb-4">
                  <img
                    src={`https://openweathermap.org/img/wn/${weather.icon}@4x.png`}
                    alt={weather.description}
                    className="w-32 h-32"
                  />
                  <div>
                    <div className="text-6xl md:text-7xl font-bold text-gray-900 dark:text-white">
                      {Math.round(weather.temperature)}
                      {getTempUnit()}
                    </div>
                    <div className="text-xl text-gray-600 dark:text-gray-400 capitalize">
                      {weather.description}
                    </div>
                  </div>
                </div>
              </div>

              {/* Weather Details Grid */}
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4 md:gap-6">
                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Wind className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Wind Speed
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {weather.windSpeed.toFixed(1)} m/s
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Droplets className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Humidity
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {weather.humidity}%
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Gauge className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Pressure
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {weather.pressure} hPa
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Eye className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Visibility
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {(weather.visibility / 1000).toFixed(1)} km
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Cloud className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Cloudiness
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {weather.clouds}%
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-gray-700 p-4 rounded-xl">
                  <div className="flex items-center gap-2 mb-2">
                    <Wind className="text-blue-600 dark:text-blue-400 w-5 h-5" />
                    <span className="text-gray-600 dark:text-gray-400 text-sm">
                      Wind Direction
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-gray-900 dark:text-white">
                    {weather.windDeg}°
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Empty State */}
          {!weather && !loading && !error && (
            <div className="p-12 text-center">
              <div className="text-6xl mb-4">🌤️</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                Search for a city
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Enter a city name to get current weather information
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default WeatherSaaSDashboard;
