#!/bin/bash

################################################################################
# APEX Performance Benchmark Script
# 
# This script runs comprehensive performance benchmarks to ensure:
# - Optimal execution times across all components
# - Memory efficiency
# - Resource utilization
# - Global performance compatibility
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BENCHMARK_DIR="./benchmark-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BENCHMARK_REPORT="${BENCHMARK_DIR}/benchmark_${TIMESTAMP}.md"

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

log_to_report() {
    echo "$1" >> "$BENCHMARK_REPORT"
}

setup_benchmark_report() {
    mkdir -p "$BENCHMARK_DIR"
    cat > "$BENCHMARK_REPORT" <<EOF
# APEX Performance Benchmark Report
**Generated:** $(date)
**Benchmark ID:** ${TIMESTAMP}

## System Information

EOF
    
    # Log system info
    log_to_report "- **OS:** $(uname -s) $(uname -r)\n"
    log_to_report "- **Architecture:** $(uname -m)\n"
    log_to_report "- **CPU:** $(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "Unknown")\n"
    log_to_report "- **CPU Cores:** $(nproc 2>/dev/null || echo "Unknown")\n"
    log_to_report "- **Total Memory:** $(free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "Unknown")\n"
    log_to_report "\n---\n\n"
}

benchmark_typescript() {
    print_section "Benchmarking TypeScript/Node.js"
    log_to_report "## TypeScript/Node.js Benchmarks\n"
    
    if [ -f "package.json" ] && command -v node &> /dev/null; then
        # Check if benchmark script exists
        if grep -q '"benchmark"' package.json; then
            print_info "Running TypeScript benchmarks..."
            START_TIME=$(date +%s%N)
            if npm run benchmark > /tmp/ts-benchmark.log 2>&1; then
                END_TIME=$(date +%s%N)
                DURATION=$((($END_TIME - $START_TIME) / 1000000))
                print_success "TypeScript benchmarks completed in ${DURATION}ms"
                log_to_report "- ✓ TypeScript benchmarks: ${DURATION}ms\n"
                log_to_report "\`\`\`\n$(cat /tmp/ts-benchmark.log)\n\`\`\`\n"
            else
                print_info "TypeScript benchmark script exists but failed to run"
                log_to_report "- ⚠ TypeScript benchmark failed\n"
            fi
        else
            print_info "No TypeScript benchmark script configured"
            log_to_report "- ℹ No TypeScript benchmark script\n"
        fi
        
        # Measure Node.js startup time
        START_TIME=$(date +%s%N)
        node -e "console.log('Node.js startup test')" > /dev/null
        END_TIME=$(date +%s%N)
        STARTUP_TIME=$((($END_TIME - $START_TIME) / 1000000))
        print_info "Node.js startup time: ${STARTUP_TIME}ms"
        log_to_report "- Node.js startup: ${STARTUP_TIME}ms\n"
    else
        print_info "TypeScript/Node.js environment not available"
        log_to_report "- ⚠ Node.js not available\n"
    fi
    
    log_to_report "\n"
}

benchmark_python() {
    print_section "Benchmarking Python"
    log_to_report "## Python Benchmarks\n"
    
    if [ -d "python" ] && command -v python3 &> /dev/null; then
        # Measure Python startup time
        START_TIME=$(date +%s%N)
        python3 -c "print('Python startup test')" > /dev/null
        END_TIME=$(date +%s%N)
        STARTUP_TIME=$((($END_TIME - $START_TIME) / 1000000))
        print_info "Python startup time: ${STARTUP_TIME}ms"
        log_to_report "- Python startup: ${STARTUP_TIME}ms\n"
        
        # Check for pytest-benchmark
        if python3 -c "import pytest_benchmark" 2>/dev/null; then
            print_info "Running Python benchmarks with pytest-benchmark..."
            if cd python && pytest --benchmark-only > /tmp/py-benchmark.log 2>&1; then
                print_success "Python benchmarks completed"
                log_to_report "- ✓ Python benchmarks completed\n"
                log_to_report "\`\`\`\n$(cat /tmp/py-benchmark.log)\n\`\`\`\n"
                cd ..
            else
                cd ..
                print_info "Python benchmarks script exists but failed"
                log_to_report "- ⚠ Python benchmark failed\n"
            fi
        else
            print_info "pytest-benchmark not installed"
            log_to_report "- ℹ pytest-benchmark not available\n"
        fi
    else
        print_info "Python environment not available"
        log_to_report "- ⚠ Python not available\n"
    fi
    
    log_to_report "\n"
}

benchmark_rust() {
    print_section "Benchmarking Rust"
    log_to_report "## Rust Benchmarks\n"
    
    if [ -d "rust" ] && command -v cargo &> /dev/null; then
        if [ -f "rust/Cargo.toml" ]; then
            print_info "Running Rust benchmarks..."
            cd rust
            if cargo bench --no-fail-fast > /tmp/rust-benchmark.log 2>&1; then
                print_success "Rust benchmarks completed"
                log_to_report "- ✓ Rust benchmarks completed\n"
                log_to_report "\`\`\`\n$(tail -n 50 /tmp/rust-benchmark.log)\n\`\`\`\n"
            else
                print_info "Rust benchmark script exists but failed or no benches defined"
                log_to_report "- ℹ No Rust benchmarks or failed\n"
            fi
            cd ..
        fi
    else
        print_info "Rust environment not available"
        log_to_report "- ⚠ Rust not available\n"
    fi
    
    log_to_report "\n"
}

benchmark_build_times() {
    print_section "Benchmarking Build Times"
    log_to_report "## Build Time Benchmarks\n"
    
    # TypeScript build time
    if [ -f "package.json" ] && grep -q '"build"' package.json; then
        print_info "Measuring TypeScript build time..."
        START_TIME=$(date +%s%N)
        if npm run build > /tmp/ts-build.log 2>&1; then
            END_TIME=$(date +%s%N)
            BUILD_TIME=$((($END_TIME - $START_TIME) / 1000000))
            print_success "TypeScript build completed in ${BUILD_TIME}ms"
            log_to_report "- ✓ TypeScript build: ${BUILD_TIME}ms\n"
        else
            print_info "TypeScript build failed or not configured"
            log_to_report "- ⚠ TypeScript build failed\n"
        fi
    fi
    
    # Rust build time
    if [ -d "rust" ] && [ -f "rust/Cargo.toml" ]; then
        print_info "Measuring Rust release build time..."
        cd rust
        # Clean build
        cargo clean > /dev/null 2>&1 || true
        START_TIME=$(date +%s%N)
        if cargo build --release > /tmp/rust-build.log 2>&1; then
            END_TIME=$(date +%s%N)
            BUILD_TIME=$((($END_TIME - $START_TIME) / 1000000))
            print_success "Rust release build completed in ${BUILD_TIME}ms"
            log_to_report "- ✓ Rust release build: ${BUILD_TIME}ms\n"
        else
            print_info "Rust build failed or not configured"
            log_to_report "- ⚠ Rust build failed\n"
        fi
        cd ..
    fi
    
    log_to_report "\n"
}

benchmark_memory() {
    print_section "Analyzing Memory Usage"
    log_to_report "## Memory Usage Analysis\n"
    
    # Get current memory usage
    if command -v free &> /dev/null; then
        TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
        USED_MEM=$(free -m | awk '/^Mem:/{print $3}')
        FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')
        USAGE_PERCENT=$(($USED_MEM * 100 / $TOTAL_MEM))
        
        print_info "System Memory: ${USED_MEM}MB / ${TOTAL_MEM}MB (${USAGE_PERCENT}%)"
        log_to_report "- Total Memory: ${TOTAL_MEM}MB\n"
        log_to_report "- Used Memory: ${USED_MEM}MB\n"
        log_to_report "- Free Memory: ${FREE_MEM}MB\n"
        log_to_report "- Usage: ${USAGE_PERCENT}%\n"
    else
        print_info "Memory analysis tools not available"
        log_to_report "- ⚠ Memory tools not available\n"
    fi
    
    log_to_report "\n"
}

benchmark_network() {
    print_section "Network Performance Tests"
    log_to_report "## Network Performance\n"
    
    # Test localhost latency
    if command -v ping &> /dev/null; then
        LATENCY=$(ping -c 4 localhost 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
        if [ -n "$LATENCY" ]; then
            print_info "Localhost latency: ${LATENCY}ms (avg)"
            log_to_report "- Localhost latency (avg): ${LATENCY}ms\n"
        fi
    fi
    
    log_to_report "\n"
}

generate_benchmark_summary() {
    print_header "BENCHMARK SUMMARY"
    
    log_to_report "## Benchmark Summary\n"
    log_to_report "All performance benchmarks have been completed. Review the detailed results above.\n\n"
    
    log_to_report "### Performance Recommendations\n"
    log_to_report "1. Monitor build times and optimize if they exceed reasonable thresholds\n"
    log_to_report "2. Ensure memory usage remains stable under load\n"
    log_to_report "3. Profile hot paths in production code\n"
    log_to_report "4. Use release builds for production deployments\n"
    log_to_report "5. Consider caching strategies for frequently accessed data\n"
    log_to_report "\n---\n"
    log_to_report "*Generated by APEX Performance Benchmark v1.0*\n"
    
    print_success "Benchmark report saved to: $BENCHMARK_REPORT"
}

main() {
    print_header "APEX Performance Benchmark"
    echo "Starting performance benchmarks..."
    echo "Report will be saved to: $BENCHMARK_REPORT"
    echo ""
    
    setup_benchmark_report
    benchmark_typescript
    benchmark_python
    benchmark_rust
    benchmark_build_times
    benchmark_memory
    benchmark_network
    generate_benchmark_summary
    
    echo ""
    print_info "Performance benchmark completed!"
}

main
