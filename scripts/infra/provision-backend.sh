#!/usr/bin/env bash
set -euo pipefail
DOMAIN="advanciapayledger.com"             # Primary apex domain (EDIT)
HOSTNAME="api.advanciapayledger.com"       # Public API FQDN (EDIT)
APP_DIR="/opt/advancia/backend"            # Deployment directory (EDIT)
GIT_REPO="https://github.com/your-org/modular-saas-platform.git" # Repo URL (EDIT)
BRANCH="main"                               # Git branch to deploy (EDIT)
MODE="ARecord"                              # ARecord or Tunnel
NODE_VERSION="20"                           # Node.js major version (EDIT)
INSTALL_NODE=1                               # 0 to skip Node install
INSTALL_PNPM=1                               # 0 to skip pnpm install (corepack alternative)
INSTALL_NGINX=1                              # 0 to skip nginx + certbot
SETUP_PM2=1                                  # 0 to skip pm2 process manager setup
RUN_MIGRATIONS=1                             # 0 to skip prisma migrate deploy
CREATE_ENV=1                                 # 0 to skip generating base .env if missing
CONFIGURE_UFW=1                              # 0 to skip firewall setup
INSTALL_FAIL2BAN=1                           # 0 to skip fail2ban hardening
SETUP_LOGROTATE=1                            # 0 to skip pm2 log rotation

log(){ echo -e "\e[36m[advancia-setup]\e[0m $*"; }
fail(){ echo "ERROR: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null || fail "Missing dependency: $1"; }

need curl; need sed; need grep; need git

log "Ensuring non-root execution recommended (current user: $(whoami))"

log "Updating system packages"; apt update -y && apt upgrade -y
apt install -y build-essential ca-certificates gnupg lsb-release unzip

if [[ $INSTALL_NODE -eq 1 ]]; then
  if ! command -v node >/dev/null; then
    log "Installing Node.js $NODE_VERSION (NodeSource)"
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt install -y nodejs
  else
    log "Node already installed: $(node -v)"
  fi
fi

if [[ $INSTALL_PNPM -eq 1 ]]; then
  if ! command -v pnpm >/dev/null; then
    log "Installing pnpm via corepack"
    corepack enable || npm install -g corepack || true
    corepack prepare pnpm@latest --activate || npm install -g pnpm
  else
    log "pnpm already installed: $(pnpm -v)"
  fi
fi

log "Base security packages"; apt install -y ca-certificates
if [[ $INSTALL_NGINX -eq 1 ]]; then
  log "Installing nginx + certbot"; apt install -y nginx certbot python3-certbot-nginx
fi

if [[ $INSTALL_FAIL2BAN -eq 1 ]]; then
  log "Installing fail2ban"; apt install -y fail2ban
  cat >/etc/fail2ban/jail.d/advancia.conf <<JAIL
[sshd]
enabled = true
port    = ssh
logpath = /var/log/auth.log
maxretry = 5
JAIL
  systemctl enable fail2ban && systemctl restart fail2ban || true
fi

if [[ $MODE == "Tunnel" ]]; then
  need cloudflared
  log "Ensure cloudflared authenticated (cloudflared login) prior to running.";
fi

log "Creating app directory if missing"; mkdir -p "$APP_DIR"

if [[ ! -d "$APP_DIR/.git" ]]; then
  log "Cloning repository $GIT_REPO (branch: $BRANCH)"
  git clone --depth 1 -b "$BRANCH" "$GIT_REPO" "$APP_DIR" || fail "Git clone failed"
else
  log "Repo already present, pulling latest"
  (cd "$APP_DIR" && git fetch origin "$BRANCH" && git reset --hard "origin/$BRANCH") || fail "Git pull failed"
fi

log "Installing backend dependencies (pnpm)"
(cd "$APP_DIR/backend" && pnpm install --frozen-lockfile || pnpm install) || fail "Dependency install failed"

if [[ $CREATE_ENV -eq 1 ]]; then
  if [[ ! -f "$APP_DIR/backend/.env" ]]; then
    log "Creating base .env file"
    cat >"$APP_DIR/backend/.env" <<ENV
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
ALLOWED_ORIGINS=https://$DOMAIN,https://www.$DOMAIN,https://app.$DOMAIN,https://$HOSTNAME
SKIP_DATABASE_VALIDATION=0
ENV
  else
    log ".env exists, not overwriting"
  fi
fi

# NGINX reverse proxy (if not using tunnel exclusively)
if [[ $INSTALL_NGINX -eq 1 ]]; then
  cat >/etc/nginx/sites-available/advancia-api <<NGINX
server {
  listen 80;
  server_name $HOSTNAME;
  location /health { proxy_pass http://127.0.0.1:4000/health; }
  location / { proxy_pass http://127.0.0.1:4000; proxy_set_header Host $host; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; }
}
NGINX
  ln -sf /etc/nginx/sites-available/advancia-api /etc/nginx/sites-enabled/advancia-api
  nginx -t && systemctl reload nginx
fi

if [[ $INSTALL_NGINX -eq 1 ]]; then
  log "Requesting certbot certificate (HTTP challenge)"; certbot --nginx -d "$HOSTNAME" --redirect --non-interactive --agree-tos -m admin@$DOMAIN || log "Certbot may be rate limited or DNS not propagated yet"
fi

# Cloudflare Tunnel mode (no open ports required if you skip nginx/cert)
if [[ $MODE == "Tunnel" ]]; then
  log "Creating tunnel config";
  mkdir -p /root/.cloudflared
  cat >/root/.cloudflared/config.yml <<CF
tunnel: advancia-backend
credentials-file: /root/.cloudflared/advancia-backend.json
ingress:
  - hostname: $HOSTNAME
    service: http://127.0.0.1:4000
  - service: http_status:404
CF
  systemctl enable cloudflared || true
  systemctl restart cloudflared || true
fi

# CORS origins update
ALLOWED="https://$DOMAIN,https://www.$DOMAIN,https://app.$DOMAIN,https://$HOSTNAME"
if [[ -f "$APP_DIR/.env" ]]; then
  sed -i "s/^ALLOWED_ORIGINS=.*/ALLOWED_ORIGINS=$ALLOWED/" "$APP_DIR/.env" || echo "ALLOWED_ORIGINS=$ALLOWED" >> "$APP_DIR/.env"
else
  echo "ALLOWED_ORIGINS=$ALLOWED" > "$APP_DIR/.env"
fi

if [[ $RUN_MIGRATIONS -eq 1 ]]; then
  log "Running prisma migrate deploy"
  (cd "$APP_DIR/backend" && npx prisma migrate deploy) || fail "Prisma migrate failed"
fi

log "Building TypeScript backend"
(cd "$APP_DIR/backend" && pnpm run build) || fail "Build failed"

if [[ $SETUP_PM2 -eq 1 ]]; then
  if ! command -v pm2 >/dev/null; then
    log "Installing PM2 globally"
    npm install -g pm2 || pnpm add -g pm2 || true
  fi
  log "Starting backend with PM2"
  (cd "$APP_DIR/backend" && pm2 start dist/index.js --name advancia-backend --time --update-env) || fail "PM2 start failed"
  pm2 save || true
  log "Configuring PM2 startup (systemd)"
  pm2 startup systemd -u $(whoami) --hp $(eval echo ~$(whoami)) >/tmp/pm2-startup.txt || true
fi

if [[ $SETUP_LOGROTATE -eq 1 ]]; then
  log "Setting up logrotate for PM2 logs"
  cat >/etc/logrotate.d/pm2-advancia <<LR
/root/.pm2/logs/*.log {
  daily
  rotate 14
  compress
  missingok
  notifempty
  copytruncate
}
LR
fi

if [[ $CONFIGURE_UFW -eq 1 ]]; then
  if command -v ufw >/dev/null; then
    log "Configuring UFW firewall rules"
    ufw allow OpenSSH || true
    [[ $INSTALL_NGINX -eq 1 ]] && ufw allow 'Nginx Full' || true
    ufw --force enable || true
  fi
fi

log "Local health probe (loopback)"
if curl -fsS "http://127.0.0.1:4000/health" >/dev/null; then
  log "Backend responded locally"
else
  log "Local health check failed (verify PM2 logs)"
  pm2 logs advancia-backend --lines 60 || true
fi

log "Public health probe (may fail until DNS + SSL ready)"
if curl -fsS "https://$HOSTNAME/health" >/dev/null; then
  log "Public health endpoint reachable"
else
  log "Public health endpoint not reachable yet (DNS/SSL/NGINX)"
fi

log "DONE. Review: PM2 status, SSL cert, firewall, .env secrets, backups.";
log "Next: configure automated DB backups (cron) and enable monitoring (Sentry, uptime)."
