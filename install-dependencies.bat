@echo off
REM Change to backend directory
echo [1/6] Installing backend dependencies...
cd /d "%~dp0backend"
REM Automated Dependency Installation Script
REM This script installs all required packages for Advancia Pay

if errorlevel 1 (
    echo ERROR: Could not change to backend directory
    pause
    exit /b 1
)

echo Installing rate limiting, validation, and encryption packages...
call npm install express-rate-limit express-validator crypto-js
if errorlevel 1 (
    echo ERROR: Backend dependencies installation failed
    pause
    exit /b 1
)

echo Installing backend dev dependencies...
call npm install --save-dev @types/crypto-js
if errorlevel 1 (
    echo ERROR: Backend dev dependencies installation failed
    pause
    exit /b 1
)

echo.
echo [2/6] Installing job queue dependencies...
call npm install bull ioredis
if errorlevel 1 (
    echo ERROR: Job queue dependencies installation failed
    pause
    exit /b 1
)

call npm install --save-dev @types/bull
if errorlevel 1 (
    echo ERROR: Job queue dev dependencies installation failed
    pause
    exit /b 1
)

echo.
echo [3/6] Running Prisma migration...
call npx prisma migrate dev --name add_job_queue_and_security
if errorlevel 1 (
    echo WARNING: Prisma migration failed or was cancelled
    echo You may need to run this manually later
)

echo.
echo [4/6] Installing frontend dependencies...
cd /d "%~dp0frontend"
if errorlevel 1 (
    echo ERROR: Could not change to frontend directory
    pause
    exit /b 1
)

echo Installing crypto and sanitization packages...
call npm install crypto-js dompurify
if errorlevel 1 (
    echo ERROR: Frontend dependencies installation failed
    pause
    exit /b 1
)

echo Installing frontend dev dependencies...
call npm install --save-dev @types/crypto-js @types/dompurify
if errorlevel 1 (
    echo ERROR: Frontend dev dependencies installation failed
    pause
    exit /b 1
)

echo.
echo [5/6] Removing optional educational files...
cd /d "%~dp0"

if exist "frontend\JAVASCRIPT_REACT_CONCEPTS.md" (
    del "frontend\JAVASCRIPT_REACT_CONCEPTS.md"
    echo Removed: JAVASCRIPT_REACT_CONCEPTS.md
)

if exist "frontend\src\components\examples\SecureLogin.tsx" (
    del "frontend\src\components\examples\SecureLogin.tsx"
    echo Removed: SecureLogin.tsx
)

if exist "frontend\src\components\examples\SafeUserProfile.tsx" (
    del "frontend\src\components\examples\SafeUserProfile.tsx"
    echo Removed: SafeUserProfile.tsx
)

if exist "frontend\src\components\examples\SecureLoginFormComplete.tsx" (
    del "frontend\src\components\examples\SecureLoginFormComplete.tsx"
    echo Removed: SecureLoginFormComplete.tsx
)

echo.
echo [6/6] Verifying installations...
cd /d "%~dp0backend"
echo.
echo Backend packages:
call npm list express-rate-limit express-validator crypto-js bull ioredis --depth=0
echo.
cd /d "%~dp0frontend"
echo Frontend packages:
call npm list crypto-js dompurify --depth=0

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Start Redis: docker run -d -p 6379:6379 redis:alpine
echo 2. Start backend: cd backend ^&^& npm run dev
echo 3. Start frontend: cd frontend ^&^& npm run dev
echo 4. Test job queue: curl http://localhost:4000/api/jobs/metrics
echo.
echo See JOB_QUEUE_QUICK_START.md for full setup guide
echo.
pause
