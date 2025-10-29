@echo off
REM APEX Arbitrage System - Installation and Startup Script (Windows)
REM This script installs dependencies and starts all required services

setlocal enabledelayedexpansion

echo ==========================================
echo APEX Arbitrage System - Installation
echo ==========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

REM Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed. Please install Node.js ^>= 16.x
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [92m✓[0m Node.js %NODE_VERSION% found

REM Check Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed. Please install Python ^>= 3.8
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo [92m✓[0m %PYTHON_VERSION% found

REM Check Rust
where rustc >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Rust is not installed. Please install Rust ^>= 1.70
    exit /b 1
)
for /f "tokens=*" %%i in ('rustc --version') do set RUST_VERSION=%%i
echo [92m✓[0m %RUST_VERSION% found

REM Check Yarn
where yarn >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Yarn is not installed. Installing Yarn...
    call npm install -g yarn
    if %errorlevel% neq 0 (
        echo Error: Failed to install Yarn
        exit /b 1
    )
)
for /f "tokens=*" %%i in ('yarn --version') do set YARN_VERSION=%%i
echo [92m✓[0m Yarn %YARN_VERSION% found

echo.
echo ==========================================
echo Installing Dependencies
echo ==========================================
echo.

REM Install TypeScript dependencies
echo Installing TypeScript dependencies...
call yarn install
if %errorlevel% neq 0 (
    echo Error: Failed to install TypeScript dependencies
    exit /b 1
)

REM Install Python dependencies
echo.
echo Installing Python dependencies...
if exist "python\requirements.txt" (
    cd python
    python -m pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo Warning: Some Python dependencies may have failed to install
    )
    cd ..
) else (
    echo Warning: python\requirements.txt not found, skipping Python dependencies
)

REM Build Rust modules
echo.
echo Building Rust modules...
if exist "rust" (
    cd rust
    cargo build --release
    if %errorlevel% neq 0 (
        echo Warning: Rust build failed
    )
    cd ..
) else (
    echo Warning: rust directory not found, skipping Rust build
)

echo.
echo ==========================================
echo Installation Complete!
echo ==========================================
echo.
echo Starting APEX Arbitrage System...
echo.
echo Starting ML Inference Server...

REM Check if Python main.py exists
if exist "python\main.py" (
    cd python
    start "APEX ML Server" python main.py
    cd ..
    echo [92m✓[0m ML Server started in new window
) else (
    echo Warning: python\main.py not found, skipping ML server
)

echo.
echo Starting TypeScript Orchestrator...
echo.

REM Run the main application
call yarn start

echo.
echo ==========================================
echo Services stopped
echo ==========================================
echo.
echo Note: ML Server may still be running in its window.
echo Please close it manually if needed.
