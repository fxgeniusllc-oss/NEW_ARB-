#!/bin/bash
# Quick validation test for APEX system
# Runs E2E validation in simulation mode

set -e

echo "========================================"
echo "APEX Quick Validation Test"
echo "========================================"
echo ""

# Check if built
if [ ! -d "dist" ]; then
    echo "Building TypeScript..."
    npm run build
fi

echo "Running E2E validation in simulation mode..."
echo ""
echo "⚠️  Using test private key - DO NOT use in production!"
echo ""

# Use environment variable if set, otherwise use test key
TEST_PRIVATE_KEY="${TEST_PRIVATE_KEY:-0x0000000000000000000000000000000000000000000000000000000000000001}"

EXECUTION_MODE=SIM \
POLYGON_RPC_URL=https://polygon-rpc.com \
PRIVATE_KEY="$TEST_PRIVATE_KEY" \
ML_SERVER_URL=http://localhost:8000 \
node dist/index.js

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "========================================"
    echo "✅ Validation PASSED"
    echo "========================================"
else
    echo "========================================"
    echo "❌ Validation FAILED"
    echo "========================================"
fi

exit $EXIT_CODE
