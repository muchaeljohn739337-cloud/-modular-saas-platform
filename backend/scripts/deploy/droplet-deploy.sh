#!/usr/bin/env bash
set -euo pipefail

# Clean droplet deployment script
# Idempotent: safe to re-run for updates.

REPO_SSH_URL="git@github.com:pdtribe181-prog/-modular-saas-platform.git"  # EDIT
BRANCH="main"                                 # EDIT (or production)
TARGET_PARENT_DIR="/var/www"                  # Base directory for clone
REPO_DIR_NAME="-modular-saas-platform"        # Folder name of repo
BACKEND_DIR="$TARGET_PARENT_DIR/$REPO_DIR_NAME/backend"
NODE_VERSION="20"                             # Node version via NodeSource
APP_NAME="advancia-backend"
ENV_FILE="$BACKEND_DIR/.env"                  # Expected env file

INSTALL_NODE=${INSTALL_NODE:-1}
INSTALL_PM2=${INSTALL_PM2:-1}
RUN_MIGRATIONS=${RUN_MIGRATIONS:-1}
BUILD_TS=${BUILD_TS:-1}
USE_PNPM=${USE_PNPM:-1}
SYSTEM_USER=${SYSTEM_USER:-$(whoami)}

log(){ echo -e "\e[34m[droplet-deploy]\e[0m $*"; }
warn(){ echo -e "\e[33m[droplet-deploy][warn]\e[0m $*"; }
fail(){ echo -e "\e[31m[droplet-deploy][error]\e[0m $*"; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || fail "Missing dependency: $1"; }

log "Starting deployment for $APP_NAME"
need git
need curl

mkdir -p "$TARGET_PARENT_DIR" || fail "Could not create $TARGET_PARENT_DIR"
cd "$TARGET_PARENT_DIR"

if [ -d "$REPO_DIR_NAME/.git" ]; then
  log "Repo exists; pulling latest ($BRANCH)"
  (cd "$REPO_DIR_NAME" && git fetch origin "$BRANCH" && git reset --hard "origin/$BRANCH") || fail "Git pull failed"
else
  log "Cloning repository $REPO_SSH_URL (branch $BRANCH)"
  git clone --depth 1 -b "$BRANCH" "$REPO_SSH_URL" "$REPO_DIR_NAME" || fail "Clone failed"
fi

cd "$BACKEND_DIR" || fail "Backend dir missing at $BACKEND_DIR"

if [ "$INSTALL_NODE" -eq 1 ]; then
  if ! command -v node >/dev/null 2>&1; then
    log "Installing Node.js $NODE_VERSION via NodeSource"
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y nodejs build-essential
  else
    log "Node already present: $(node -v)"
  fi
fi

if [ "$USE_PNPM" -eq 1 ]; then
  if ! command -v pnpm >/dev/null 2>&1; then
    log "Installing pnpm via corepack"
    corepack enable || npm install -g corepack || true
    corepack prepare pnpm@latest --activate || npm install -g pnpm || true
  fi
  PKG_INSTALLER="pnpm install --frozen-lockfile || pnpm install"
else
  PKG_INSTALLER="npm install --no-audit --no-fund"
fi

log "Installing dependencies"
eval $PKG_INSTALLER || fail "Dependency install failed"

log "Generating Prisma client"
npx prisma generate || fail "Prisma client generation failed"

if [ ! -f "$ENV_FILE" ]; then
  warn "Env file $ENV_FILE missing. Creating template (EDIT SECRETS before restart)."
  cat > "$ENV_FILE" <<ENV
NODE_ENV=production
PORT=4000
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/advancia_db?schema=public
JWT_SECRET=$(openssl rand -hex 32)
STRIPE_SECRET_KEY=sk_test_replace
STRIPE_WEBHOOK_SECRET=whsec_replace
CRYPTOMUS_API_KEY=replace
CRYPTOMUS_MERCHANT_ID=replace
EMAIL_USER=replace
EMAIL_PASSWORD=replace
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SENTRY_DSN=
ALLOWED_ORIGINS=https://advanciapayledger.com,https://www.advanciapayledger.com,https://app.advanciapayledger.com,https://api.advanciapayledger.com
SKIP_DATABASE_VALIDATION=0
ENV
fi

if [ "$RUN_MIGRATIONS" -eq 1 ]; then
  if grep -q 'DATABASE_URL' "$ENV_FILE"; then
    log "Running prisma migrate deploy"
    npx prisma migrate deploy || fail "Migration failed"
  else
    warn "DATABASE_URL not set in $ENV_FILE; skipping migrations"
  fi
fi

if [ "$BUILD_TS" -eq 1 ]; then
  if grep -q '"build"' package.json; then
    log "Building TypeScript"
    (npm run build || pnpm run build) || fail "Build failed"
  else
    warn "No build script found; skipping"
  fi
fi

if [ "$INSTALL_PM2" -eq 1 ]; then
  if ! command -v pm2 >/dev/null 2>&1; then
    log "Installing PM2 globally"
    npm install -g pm2 || pnpm add -g pm2 || true
  fi
  START_CMD="dist/index.js"
  if [ ! -f dist/index.js ]; then
    warn "dist/index.js missing; falling back to src/index.ts with ts-node"
    START_CMD="node_modules/.bin/ts-node src/index.ts"
  fi
  if pm2 list | grep -q "$APP_NAME"; then
    log "Reloading existing PM2 app"
    pm2 restart "$APP_NAME" || pm2 reload "$APP_NAME" || true
  else
    log "Starting PM2 app ($START_CMD)"
    pm2 start $START_CMD --name "$APP_NAME" --time --update-env
  fi
  pm2 save || warn "PM2 save failed (non-fatal)"
fi

log "Local health probe"
if curl -fsS http://127.0.0.1:4000/health >/dev/null 2>&1; then
  log "Health OK (local)"
else
  warn "Health endpoint not responding locally; check PM2 logs"
  pm2 logs "$APP_NAME" --lines 50 || true
fi

log "Done. Next: configure nginx/SSL, backups, monitoring."
echo "Commands: pm2 status; pm2 logs $APP_NAME --lines 100" 

exit 0
