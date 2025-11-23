@echo off
REM Complete Setup and Start Script for Advancia Pay

echo ========================================
echo Advancia Pay - Complete Setup
echo ========================================
echo.

REM Check if dependencies are installed
if not exist "backend\node_modules\express-rate-limit" (
    echo Dependencies not found. Running installation...
    call install-dependencies.bat
    if errorlevel 1 (
        echo ERROR: Dependency installation failed
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Starting Services
echo ========================================
echo.

REM Check if Redis is running
docker ps | findstr advancia-redis >nul 2>&1
if errorlevel 1 (
    echo Redis not running. Starting Redis...
    call setup-redis.bat
    if errorlevel 1 (
        echo ERROR: Could not start Redis
        pause
        exit /b 1
    )
) else (
    echo Redis is already running
)

echo.
echo Starting backend and frontend...
echo.
echo Opening 2 new command windows:
echo   - Backend: http://localhost:4000
echo   - Frontend: http://localhost:3000
echo.

REM Start backend in new window
start "Advancia Pay Backend" cmd /k "cd /d %~dp0backend && npm run dev"

REM Wait 3 seconds for backend to start
timeout /t 3 >nul

REM Start frontend in new window
start "Advancia Pay Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"

echo.
echo ========================================
echo Services Started!
echo ========================================
echo.
echo Backend: http://localhost:4000
echo Frontend: http://localhost:3000
echo Job Queue Metrics: http://localhost:4000/api/jobs/metrics
echo.
echo Check the opened windows for logs
echo Press Ctrl+C in each window to stop services
echo.
pause
