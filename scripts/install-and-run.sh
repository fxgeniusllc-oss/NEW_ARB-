#!/bin/bash
# APEX Arbitrage System - Installation and Startup Script
# This script installs dependencies and starts all required services

set -e

echo "=========================================="
echo "APEX Arbitrage System - Installation"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js >= 16.x"
    exit 1
fi
echo "✓ Node.js $(node --version) found"

# Check Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "Error: Python is not installed. Please install Python >= 3.8"
    exit 1
fi
PYTHON_CMD=$(command -v python3 || command -v python)
echo "✓ Python $($PYTHON_CMD --version) found"

# Check Rust
if ! command -v rustc &> /dev/null; then
    echo "Error: Rust is not installed. Please install Rust >= 1.70"
    exit 1
fi
echo "✓ Rust $(rustc --version) found"

# Check Yarn
if ! command -v yarn &> /dev/null; then
    echo "Warning: Yarn is not installed. Installing Yarn..."
    npm install -g yarn
fi
echo "✓ Yarn $(yarn --version) found"

echo ""
echo "=========================================="
echo "Installing Dependencies"
echo "=========================================="
echo ""

# Install TypeScript dependencies
echo "Installing TypeScript dependencies..."
yarn install

# Install Python dependencies
echo ""
echo "Installing Python dependencies..."
if [ -f "python/requirements.txt" ]; then
    cd python
    $PYTHON_CMD -m pip install -r requirements.txt
    cd ..
else
    echo "Warning: python/requirements.txt not found, skipping Python dependencies"
fi

# Build Rust modules
echo ""
echo "Building Rust modules..."
if [ -d "rust" ]; then
    cd rust
    cargo build --release
    cd ..
else
    echo "Warning: rust directory not found, skipping Rust build"
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Starting APEX Arbitrage System..."
echo ""
echo "Starting ML Inference Server..."

# Check if Python main.py exists
if [ -f "python/main.py" ]; then
    cd python
    $PYTHON_CMD main.py &
    PYTHON_PID=$!
    cd ..
    echo "✓ ML Server started (PID: $PYTHON_PID)"
else
    echo "Warning: python/main.py not found, skipping ML server"
fi

echo ""
echo "Starting TypeScript Orchestrator..."
echo ""

# Run the main application
yarn start

# Cleanup
if [ ! -z "$PYTHON_PID" ]; then
    echo ""
    echo "Shutting down services..."
    kill $PYTHON_PID 2>/dev/null || true
fi
