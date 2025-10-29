#!/bin/bash
# APEX Arbitrage System - End-to-End Validation Script
# This script validates all operations from data fetch to blockchain broadcast

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "APEX End-to-End Validation"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Check environment
echo "Checking environment..."
echo ""

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js installed: $NODE_VERSION"
else
    print_status 1 "Node.js not found"
    exit 1
fi

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_status 0 "Python installed: $PYTHON_VERSION"
else
    print_status 1 "Python3 not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Building TypeScript Project"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
fi

# Build TypeScript
echo "Compiling TypeScript..."
npm run build

if [ $? -eq 0 ]; then
    print_status 0 "TypeScript compilation successful"
else
    print_status 1 "TypeScript compilation failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "Starting ML Server (Background)"
echo "=========================================="
echo ""

# Check if Python dependencies are installed
if [ ! -d "python/venv" ]; then
    echo "Creating Python virtual environment..."
    cd python
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..
else
    source python/venv/bin/activate
fi

# Start ML server in background
echo "Starting ML inference server..."
cd python
python3 main.py &
ML_SERVER_PID=$!
cd ..

# Wait for ML server to start
echo "Waiting for ML server to start..."
sleep 5

# Check if ML server is running
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    print_status 0 "ML server started successfully"
else
    print_status 1 "ML server failed to start (will use fallback)"
fi

echo ""
echo "=========================================="
echo "Running End-to-End Validation"
echo "=========================================="
echo ""

# Set environment for simulation mode
export EXECUTION_MODE=SIM
export ML_SERVER_URL=http://localhost:8000

# Run the validation
node dist/index.js

VALIDATION_RESULT=$?

echo ""
echo "=========================================="
echo "Cleanup"
echo "=========================================="
echo ""

# Stop ML server
if [ ! -z "$ML_SERVER_PID" ]; then
    echo "Stopping ML server..."
    kill $ML_SERVER_PID 2>/dev/null || true
    print_status 0 "ML server stopped"
fi

echo ""
echo "=========================================="
echo "Validation Complete"
echo "=========================================="
echo ""

if [ $VALIDATION_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ All validation stages passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validation stages failed. Check logs above.${NC}"
    exit 1
fi
