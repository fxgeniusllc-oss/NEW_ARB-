@echo off
REM APEX Arbitrage System - Validation Script (Windows)
REM This script runs all tests and validates the system

setlocal enabledelayedexpansion

echo ==========================================
echo APEX Arbitrage System - Validation
echo ==========================================
echo.

REM Check if required directories exist
echo Checking project structure...

set "DIRS=src python rust docs"
for %%d in (%DIRS%) do (
    if exist "%%d" (
        echo [92m✓[0m %%d\ directory found
    ) else (
        echo [91m✗[0m %%d\ directory missing ^(expected based on documentation^)
    )
)

echo.
echo ==========================================
echo Running TypeScript Tests
echo ==========================================
echo.

REM Check if package.json exists
if exist "package.json" (
    findstr /C:"\"test\"" package.json >nul 2>&1
    if %errorlevel% equ 0 (
        call yarn test
        if %errorlevel% neq 0 (
            echo Warning: TypeScript tests failed or not configured
        )
    ) else (
        echo No test script found in package.json
    )
) else (
    echo Warning: package.json not found, skipping TypeScript tests
)

echo.
echo ==========================================
echo Running Python Tests
echo ==========================================
echo.

REM Run Python tests
if exist "python" (
    cd python
    where pytest >nul 2>&1
    if %errorlevel% equ 0 (
        python -m pytest
        if %errorlevel% neq 0 (
            echo Warning: Python tests failed or no tests found
        )
    ) else (
        echo pytest not installed, skipping Python tests
    )
    cd ..
) else (
    echo Warning: python directory not found, skipping Python tests
)

echo.
echo ==========================================
echo Running Rust Tests
echo ==========================================
echo.

REM Run Rust tests
if exist "rust" (
    cd rust
    if exist "Cargo.toml" (
        cargo test
        if %errorlevel% neq 0 (
            echo Warning: Rust tests failed or not configured
        )
    ) else (
        echo Cargo.toml not found
    )
    cd ..
) else (
    echo Warning: rust directory not found, skipping Rust tests
)

echo.
echo ==========================================
echo Running Integration Tests
echo ==========================================
echo.

REM Check if package.json exists and has integration test script
if exist "package.json" (
    findstr /C:"\"test:integration\"" package.json >nul 2>&1
    if %errorlevel% equ 0 (
        call yarn test:integration
        if %errorlevel% neq 0 (
            echo Warning: Integration tests failed or not configured
        )
    ) else (
        echo No integration test script found in package.json
    )
) else (
    echo Warning: package.json not found, skipping integration tests
)

echo.
echo ==========================================
echo Validation Complete!
echo ==========================================
echo.
echo Review the results above to ensure all tests passed.
echo.
pause
