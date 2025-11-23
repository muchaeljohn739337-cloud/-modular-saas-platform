FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies (use npm install as fallback for workspace issues)
RUN npm install --legacy-peer-deps || npm ci --legacy-peer-deps || npm install

# Copy source and Prisma schema
COPY src ./src
COPY prisma ./prisma

# Generate Prisma Client
RUN npx prisma generate

# Build TypeScript (produces dist/)
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package files & prisma config
COPY package*.json ./
COPY prisma.config.ts ./

ENV NODE_ENV=production
# Install production dependencies only (ensure adapter + pg present)
RUN npm install --production --legacy-peer-deps || npm ci --only=production --legacy-peer-deps
RUN npm install @prisma/adapter-pg pg --legacy-peer-deps || true

COPY prisma ./prisma
# Generate Prisma client using prisma.config.ts (adapter-ready)
RUN npx prisma generate

COPY --from=builder /app/dist ./dist
# Optional: retain source for stack traces
COPY --from=builder /app/src ./src

ENV PORT=4000
# Install curl for healthcheck
RUN apk add --no-cache curl

EXPOSE 4000

# Run compiled output
CMD ["node", "dist/index.js"]
