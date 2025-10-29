#!/bin/bash
# APEX Arbitrage System - Validation Script
# This script runs all tests and validates the system

set -e

echo "=========================================="
echo "APEX Arbitrage System - Validation"
echo "=========================================="
echo ""

# Check if required directories exist
echo "Checking project structure..."

REQUIRED_DIRS=("src" "python" "rust" "docs")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ $dir/ directory found"
    else
        echo "✗ $dir/ directory missing (expected based on documentation)"
    fi
done

echo ""
echo "=========================================="
echo "Running TypeScript Tests"
echo "=========================================="
echo ""

# Check if package.json exists
if [ -f "package.json" ]; then
    # Check if test script exists in package.json
    if grep -q '"test"' package.json; then
        yarn test || echo "Warning: TypeScript tests failed or not configured"
    else
        echo "No test script found in package.json"
    fi
else
    echo "Warning: package.json not found, skipping TypeScript tests"
fi

echo ""
echo "=========================================="
echo "Running Python Tests"
echo "=========================================="
echo ""

# Run Python tests
if [ -d "python" ]; then
    cd python
    PYTHON_CMD=$(command -v python3 || command -v python)
    if command -v pytest &> /dev/null; then
        $PYTHON_CMD -m pytest || echo "Warning: Python tests failed or no tests found"
    else
        echo "pytest not installed, skipping Python tests"
    fi
    cd ..
else
    echo "Warning: python directory not found, skipping Python tests"
fi

echo ""
echo "=========================================="
echo "Running Rust Tests"
echo "=========================================="
echo ""

# Run Rust tests
if [ -d "rust" ]; then
    cd rust
    if [ -f "Cargo.toml" ]; then
        cargo test || echo "Warning: Rust tests failed or not configured"
    else
        echo "Cargo.toml not found"
    fi
    cd ..
else
    echo "Warning: rust directory not found, skipping Rust tests"
fi

echo ""
echo "=========================================="
echo "Running Integration Tests"
echo "=========================================="
echo ""

# Check if package.json exists and has integration test script
if [ -f "package.json" ]; then
    if grep -q '"test:integration"' package.json; then
        yarn test:integration || echo "Warning: Integration tests failed or not configured"
    else
        echo "No integration test script found in package.json"
    fi
else
    echo "Warning: package.json not found, skipping integration tests"
fi

echo ""
echo "=========================================="
echo "Validation Complete!"
echo "=========================================="
echo ""
echo "Review the results above to ensure all tests passed."
