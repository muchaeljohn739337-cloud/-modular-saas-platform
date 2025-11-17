module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src", "<rootDir>/tests"],
  testMatch: ["**/__tests__/**/*.ts", "**/?(*.)+(spec|test).ts"],
  transform: {
    "^.+\\.tsx?$": [
      "ts-jest",
      {
        tsconfig: "tsconfig.json",
        useESM: true,
      },
    ],
  },
  // Treat .ts files as ESM when project is ESM
  extensionsToTreatAsEsm: [".ts"],
  globals: {
    "ts-jest": {
      tsconfig: "tsconfig.json",
      useESM: true,
    },
  },
  collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts", "!src/index.ts"],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html", "json-summary"],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  setupFilesAfterEnv: ["<rootDir>/tests/setup.cjs"],
  globalSetup: "<rootDir>/tests/globalSetup.cjs",
  globalTeardown: "<rootDir>/tests/globalTeardown.cjs",
  testTimeout: 30000,
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  testPathIgnorePatterns: ["/node_modules/", "/dist/"],
  coveragePathIgnorePatterns: ["/node_modules/", "/dist/"],
  // Run tests serially to prevent database deadlocks
  maxWorkers: 1,
  // Force exit after tests complete
  forceExit: true,
  // Detect open handles (async operations that prevent Jest from exiting)
  detectOpenHandles: true,
};
