#!/bin/bash
# Start Production Services
cd /var/www/advancia

echo "Starting services with PM2..."
if [ -f "ecosystem.config.js" ]; then
    pm2 start ecosystem.config.js
else
    echo "ecosystem.config.js not found, starting manually..."
    cd backend && pm2 start npm --name "advancia-backend" -- start
    cd ../frontend && pm2 start npm --name "advancia-frontend" -- start
fi

pm2 save
pm2 list
echo ""
echo "Services started! Check status above."
