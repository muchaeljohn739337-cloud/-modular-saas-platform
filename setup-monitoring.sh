#!/bin/bash

# Monitoring Setup Script for Advancia Pay Ledger
# Sets up basic monitoring and alerting

echo "📊 Setting up Monitoring & Alerting"
echo "==================================="

# Create monitoring directory
if [ ! -d "monitoring" ]; then
    mkdir -p monitoring
    echo "✅ Created monitoring directory"
fi

# Create health check script
if [ ! -f "monitoring/health-check.js" ]; then
    cat > monitoring/health-check.js << 'EOF'
#!/usr/bin/env node

/**
 * Health Check Script
 * Monitors application health and sends alerts
 */

const http = require('http');
const https = require('https');

const HEALTH_CHECK_CONFIG = {
    url: process.env.HEALTH_CHECK_URL || 'http://localhost:5000/health',
    interval: parseInt(process.env.HEALTH_CHECK_INTERVAL) || 30000, // 30 seconds
    timeout: parseInt(process.env.HEALTH_CHECK_TIMEOUT) || 5000,   // 5 seconds
    maxFailures: parseInt(process.env.HEALTH_CHECK_MAX_FAILURES) || 3,
    alertEmail: process.env.ALERT_EMAIL || 'admin@yourdomain.com'
};

let failureCount = 0;
let lastSuccess = new Date();

function checkHealth() {
    return new Promise((resolve, reject) => {
        const url = new URL(HEALTH_CHECK_CONFIG.url);
        const client = url.protocol === 'https:' ? https : http;

        const options = {
            hostname: url.hostname,
            port: url.port,
            path: url.pathname,
            method: 'GET',
            timeout: HEALTH_CHECK_CONFIG.timeout
        };

        const req = client.request(options, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                if (res.statusCode === 200) {
                    try {
                        const health = JSON.parse(data);
                        if (health.status === 'healthy') {
                            resolve(health);
                        } else {
                            reject(new Error(`Health check failed: ${JSON.stringify(health)}`));
                        }
                    } catch (error) {
                        reject(new Error(`Invalid health response: ${error.message}`));
                    }
                } else {
                    reject(new Error(`HTTP ${res.statusCode}: ${data}`));
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.on('timeout', () => {
            req.destroy();
            reject(new Error('Health check timeout'));
        });

        req.end();
    });
}

async function performHealthCheck() {
    try {
        const health = await checkHealth();

        if (failureCount > 0) {
            console.log(`✅ Health check recovered after ${failureCount} failures`);
            failureCount = 0;
        }

        lastSuccess = new Date();
        console.log(`✅ Health check passed at ${lastSuccess.toISOString()}`);
        console.log(`   Status: ${health.status}`);
        console.log(`   Uptime: ${health.uptime}s`);
        console.log(`   Memory: ${Math.round(health.memory / 1024 / 1024)}MB`);

    } catch (error) {
        failureCount++;
        console.error(`❌ Health check failed (${failureCount}/${HEALTH_CHECK_CONFIG.maxFailures}): ${error.message}`);

        if (failureCount >= HEALTH_CHECK_CONFIG.maxFailures) {
            console.error('🚨 Maximum failures reached! Sending alert...');
            sendAlert(error.message);
            failureCount = 0; // Reset to avoid spam
        }
    }
}

function sendAlert(message) {
    // In production, integrate with email service, Slack, PagerDuty, etc.
    console.error(`🚨 ALERT: ${message}`);
    console.error(`   Time: ${new Date().toISOString()}`);
    console.error(`   Last Success: ${lastSuccess.toISOString()}`);
    console.error(`   Alert Email: ${HEALTH_CHECK_CONFIG.alertEmail}`);

    // TODO: Implement actual alerting (email, Slack, etc.)
}

function startMonitoring() {
    console.log('🏥 Starting health monitoring...');
    console.log(`   URL: ${HEALTH_CHECK_CONFIG.url}`);
    console.log(`   Interval: ${HEALTH_CHECK_CONFIG.interval}ms`);
    console.log(`   Timeout: ${HEALTH_CHECK_CONFIG.timeout}ms`);
    console.log(`   Max Failures: ${HEALTH_CHECK_CONFIG.maxFailures}`);
    console.log('');

    // Initial check
    performHealthCheck();

    // Set up interval
    setInterval(performHealthCheck, HEALTH_CHECK_CONFIG.interval);
}

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Stopping health monitoring...');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Stopping health monitoring...');
    process.exit(0);
});

// Start monitoring if run directly
if (require.main === module) {
    startMonitoring();
}

module.exports = { checkHealth, performHealthCheck };
EOF
    chmod +x monitoring/health-check.js
    echo "✅ Created monitoring/health-check.js"
fi

# Create log monitoring script
if [ ! -f "monitoring/log-monitor.js" ]; then
    cat > monitoring/log-monitor.js << 'EOF'
#!/usr/bin/env node

/**
 * Log Monitoring Script
 * Monitors application logs for errors and security events
 */

const fs = require('fs');
const path = require('path');

const LOG_CONFIG = {
    logFile: process.env.LOG_FILE || 'logs/app.log',
    errorPatterns: [
        /ERROR/i,
        /WARN/i,
        /SECURITY/i,
        /UNAUTHORIZED/i,
        /RATE_LIMIT/i,
        /SQL/i,
        /INJECTION/i
    ],
    checkInterval: parseInt(process.env.LOG_CHECK_INTERVAL) || 10000, // 10 seconds
    maxLines: parseInt(process.env.LOG_MAX_LINES) || 1000
};

let lastPosition = 0;
let errorCount = 0;

function monitorLogs() {
    const logPath = path.resolve(LOG_CONFIG.logFile);

    if (!fs.existsSync(logPath)) {
        console.log(`📝 Log file not found: ${logPath}`);
        return;
    }

    try {
        const stats = fs.statSync(logPath);
        const currentSize = stats.size;

        if (currentSize < lastPosition) {
            // Log file was rotated
            console.log('🔄 Log file rotated, resetting position');
            lastPosition = 0;
        }

        if (currentSize > lastPosition) {
            const stream = fs.createReadStream(logPath, {
                start: lastPosition,
                end: currentSize
            });

            let newData = '';
            stream.on('data', (chunk) => {
                newData += chunk.toString();
            });

            stream.on('end', () => {
                const lines = newData.split('\n').filter(line => line.trim());

                lines.forEach(line => {
                    LOG_CONFIG.errorPatterns.forEach(pattern => {
                        if (pattern.test(line)) {
                            errorCount++;
                            console.log(`🚨 Log Alert [${errorCount}]: ${line.substring(0, 200)}...`);
                        }
                    });
                });

                lastPosition = currentSize;
            });

            stream.on('error', (error) => {
                console.error(`❌ Error reading log file: ${error.message}`);
            });
        }

    } catch (error) {
        console.error(`❌ Error monitoring logs: ${error.message}`);
    }
}

function startLogMonitoring() {
    console.log('📋 Starting log monitoring...');
    console.log(`   Log File: ${LOG_CONFIG.logFile}`);
    console.log(`   Check Interval: ${LOG_CONFIG.checkInterval}ms`);
    console.log(`   Error Patterns: ${LOG_CONFIG.errorPatterns.length}`);
    console.log('');

    // Initial check
    monitorLogs();

    // Set up interval
    setInterval(monitorLogs, LOG_CONFIG.checkInterval);
}

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Stopping log monitoring...');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Stopping log monitoring...');
    process.exit(0);
});

// Start monitoring if run directly
if (require.main === module) {
    startLogMonitoring();
}

module.exports = { monitorLogs };
EOF
    chmod +x monitoring/log-monitor.js
    echo "✅ Created monitoring/log-monitor.js"
fi

# Create monitoring dashboard script
if [ ! -f "monitoring/dashboard.js" ]; then
    cat > monitoring/dashboard.js << 'EOF'
#!/usr/bin/env node

/**
 * Monitoring Dashboard
 * Displays real-time application metrics
 */

const os = require('os');
const { checkHealth } = require('./health-check');

const DASHBOARD_CONFIG = {
    updateInterval: parseInt(process.env.DASHBOARD_UPDATE_INTERVAL) || 5000, // 5 seconds
    showSystemInfo: process.env.SHOW_SYSTEM_INFO !== 'false'
};

async function displayDashboard() {
    console.clear();
    console.log('📊 Advancia Pay Ledger - Monitoring Dashboard');
    console.log('==============================================');
    console.log(`Time: ${new Date().toISOString()}`);
    console.log('');

    // System Information
    if (DASHBOARD_CONFIG.showSystemInfo) {
        console.log('🖥️  System Information:');
        console.log(`   CPU: ${os.cpus().length} cores`);
        console.log(`   Memory: ${Math.round(os.totalmem() / 1024 / 1024 / 1024)}GB total`);
        console.log(`   Uptime: ${Math.round(os.uptime() / 3600)} hours`);
        console.log('');
    }

    // Application Health
    try {
        const health = await checkHealth();
        console.log('🏥 Application Health:');
        console.log(`   Status: ✅ ${health.status}`);
        console.log(`   Uptime: ${Math.round(health.uptime / 3600)}h ${Math.round((health.uptime % 3600) / 60)}m`);
        console.log(`   Memory Usage: ${Math.round(health.memory / 1024 / 1024)}MB`);
        console.log(`   Database: ${health.database ? '✅ Connected' : '❌ Disconnected'}`);
        console.log(`   Redis: ${health.redis ? '✅ Connected' : '❌ Disconnected'}`);
    } catch (error) {
        console.log('🏥 Application Health:');
        console.log(`   Status: ❌ Unhealthy`);
        console.log(`   Error: ${error.message}`);
    }

    console.log('');
    console.log('🔄 Refreshing every', DASHBOARD_CONFIG.updateInterval / 1000, 'seconds...');
    console.log('Press Ctrl+C to exit');
}

function startDashboard() {
    console.log('📊 Starting monitoring dashboard...');

    // Initial display
    displayDashboard();

    // Set up interval
    setInterval(displayDashboard, DASHBOARD_CONFIG.updateInterval);
}

// Graceful shutdown
process.on('SIGINT', () => {
    console.clear();
    console.log('👋 Monitoring dashboard stopped');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('👋 Monitoring dashboard stopped');
    process.exit(0);
});

// Start monitoring if run directly
if (require.main === module) {
    startDashboard();
}

module.exports = { displayDashboard };
EOF
    chmod +x monitoring/dashboard.js
    echo "✅ Created monitoring/dashboard.js"
fi

# Create PM2 ecosystem file for production monitoring
if [ ! -f "ecosystem-monitoring.json" ]; then
    cat > ecosystem-monitoring.json << 'EOF'
{
  "apps": [
    {
      "name": "advancia-backend",
      "script": "dist/src/index.js",
      "instances": 1,
      "autorestart": true,
      "watch": false,
      "max_memory_restart": "1G",
      "env": {
        "NODE_ENV": "production"
      },
      "error_file": "logs/pm2-error.log",
      "out_file": "logs/pm2-out.log",
      "log_file": "logs/pm2-combined.log"
    },
    {
      "name": "health-monitor",
      "script": "monitoring/health-check.js",
      "instances": 1,
      "autorestart": true,
      "watch": false,
      "env": {
        "NODE_ENV": "production",
        "HEALTH_CHECK_URL": "http://localhost:5000/health",
        "HEALTH_CHECK_INTERVAL": "30000",
        "HEALTH_CHECK_TIMEOUT": "5000",
        "HEALTH_CHECK_MAX_FAILURES": "3"
      }
    },
    {
      "name": "log-monitor",
      "script": "monitoring/log-monitor.js",
      "instances": 1,
      "autorestart": true,
      "watch": false,
      "env": {
        "NODE_ENV": "production",
        "LOG_FILE": "logs/app.log",
        "LOG_CHECK_INTERVAL": "10000"
      }
    }
  ]
}
EOF
    echo "✅ Created ecosystem-monitoring.json"
fi

echo ""
echo "🎉 Monitoring setup complete!"
echo ""
echo "📋 Available monitoring tools:"
echo "   - Health Check: node monitoring/health-check.js"
echo "   - Log Monitor: node monitoring/log-monitor.js"
echo "   - Dashboard: node monitoring/dashboard.js"
echo "   - PM2 Config: ecosystem-monitoring.json"
echo ""
echo "🔧 For production monitoring, consider:"
echo "   - Prometheus + Grafana for metrics"
echo "   - ELK Stack for log aggregation"
echo "   - Sentry for error tracking"
echo "   - DataDog or New Relic for APM"
echo ""
echo "📊 Quick start:"
echo "   pm2 start ecosystem-monitoring.json"