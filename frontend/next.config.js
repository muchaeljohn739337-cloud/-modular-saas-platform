/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  productionBrowserSourceMaps: false,

  // Disable static optimization for pages that use browser-only APIs
  experimental: {
    serverComponentsExternalPackages: [],
    // Disable static optimization
    serverActions: false,
  },

  // Force dynamic rendering for problematic pages
  generateBuildId: async () => {
    return 'build-' + Date.now()
  },

  // Disable static generation for specific pages
  trailingSlash: false,

  // Disable styled-jsx to avoid SSR context issues
  styledJsx: false,
};

module.exports = nextConfig;
