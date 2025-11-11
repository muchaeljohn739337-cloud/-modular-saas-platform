module.exports = {
  // Backend TypeScript files
  'backend/**/*.{ts,tsx}': [
    'prettier --write',
    // Skip lint for now since it's disabled in package.json
  ],
  
  // Frontend TypeScript/JavaScript files
  'frontend/**/*.{ts,tsx,js,jsx}': [
    'prettier --write',
  ],
  
  // JSON files
  '**/*.json': [
    'prettier --write',
  ],
  
  // Markdown files
  '**/*.md': [
    'prettier --write',
  ],
  
  // Run backend tests on backend changes
  'backend/src/**/*.ts': () => 'cd backend && npm test -- --bail --findRelatedTests',
};
