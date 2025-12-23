@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║           QR.DEV - AI Coding Assistant                     ║
echo ║           Powered by Quantum Rishi                         ║
echo ║           Launching from: %cd%
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: Memory optimization for Node.js
set NODE_OPTIONS=--max-old-space-size=8192

:: Check if pnpm is available
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pnpm is not installed. Installing via npm...
    call npm install -g pnpm
    if %errorlevel% neq 0 (
        echo [FATAL] Failed to install pnpm
        pause
        exit /b 1
    )
)

echo [1/4] Building Electron dependencies...
call pnpm run electron:build:deps
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build electron dependencies
    pause
    exit /b 1
)
echo [OK] Electron dependencies built

echo [2/4] Starting Remix development server...
start "QR.dev Server" cmd /k "cd /d %cd% && set NODE_OPTIONS=--max-old-space-size=8192 && pnpm run dev"

echo [3/4] Waiting for server to be ready on port 5173...
set /a attempts=0
set /a max_attempts=30

:wait_loop
set /a attempts+=1
if !attempts! gtr !max_attempts! (
    echo [ERROR] Server failed to start within 60 seconds
    pause
    exit /b 1
)

:: Check if port 5173 is listening
netstat -an | findstr ":5173.*LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Server is ready!
    goto server_ready
)

echo     Attempt !attempts!/!max_attempts! - waiting...
timeout /t 2 /nobreak >nul
goto wait_loop

:server_ready
echo [4/4] Launching Electron app...
call pnpx electron build/electron/main/index.mjs

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║           QR.dev launched successfully!                    ║
echo ╚════════════════════════════════════════════════════════════╝
pause