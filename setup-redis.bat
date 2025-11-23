@echo off
REM Redis Setup Script for Advancia Pay Job Queue

echo ========================================
echo Advancia Pay - Redis Setup
echo ========================================
echo.

echo Checking for Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed or not in PATH
    echo.
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop
    echo.
    echo OR install Redis directly:
    echo https://github.com/microsoftarchive/redis/releases
    echo.
    pause
    exit /b 1
)

echo Docker found! Starting Redis container...
echo.

REM Stop existing Redis container if running
docker stop advancia-redis >nul 2>&1
docker rm advancia-redis >nul 2>&1

REM Start new Redis container
echo Starting Redis on port 6379...
docker run -d ^
    --name advancia-redis ^
    -p 6379:6379 ^
    --restart unless-stopped ^
    redis:alpine

if errorlevel 1 (
    echo ERROR: Failed to start Redis container
    pause
    exit /b 1
)

echo.
echo ========================================
echo Redis is now running!
echo ========================================
echo.
echo Container name: advancia-redis
echo Port: 6379
echo Image: redis:alpine
echo.
echo To check status: docker ps
echo To view logs: docker logs advancia-redis
echo To stop: docker stop advancia-redis
echo To start again: docker start advancia-redis
echo.
echo Testing connection...
timeout /t 2 >nul
docker exec advancia-redis redis-cli ping

if errorlevel 1 (
    echo WARNING: Could not connect to Redis
) else (
    echo.
    echo Redis is responding correctly!
)

echo.
echo You can now start the backend with: cd backend ^&^& npm run dev
echo.
pause
