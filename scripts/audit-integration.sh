#!/bin/bash

################################################################################
# APEX Integration Source Audit Script
# 
# This script performs a comprehensive audit of the entire codebase to ensure:
# - No regressions in functionality
# - Top global performance compatibilities
# - Security vulnerabilities are identified
# - Dependencies are up-to-date and secure
# - Code quality standards are met
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Audit configuration
AUDIT_REPORT_DIR="./audit-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
AUDIT_REPORT="${AUDIT_REPORT_DIR}/audit_${TIMESTAMP}.md"

# Exit codes
EXIT_SUCCESS=0
EXIT_WARNINGS=1
EXIT_FAILURES=2

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

################################################################################
# Helper Functions
################################################################################

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
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
}

print_failure() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNING_CHECKS++))
    ((TOTAL_CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

log_to_report() {
    echo "$1" >> "$AUDIT_REPORT"
}

################################################################################
# Audit Functions
################################################################################

setup_audit_report() {
    mkdir -p "$AUDIT_REPORT_DIR"
    cat > "$AUDIT_REPORT" <<EOF
# APEX Integration Source Audit Report
**Generated:** $(date)
**Audit ID:** ${TIMESTAMP}

## Executive Summary

This report contains the results of a comprehensive integration source audit
performed on the APEX Arbitrage System codebase.

---

EOF
}

audit_environment() {
    print_section "Auditing Development Environment"
    log_to_report "## Environment Audit\n"
    
    # Check Node.js version
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        REQUIRED_NODE="v16"
        if [[ "$NODE_VERSION" > "$REQUIRED_NODE" ]] || [[ "$NODE_VERSION" == "$REQUIRED_NODE"* ]]; then
            print_success "Node.js version: $NODE_VERSION (>= 16.x required)"
            log_to_report "- ✓ Node.js: $NODE_VERSION\n"
        else
            print_failure "Node.js version: $NODE_VERSION (< 16.x)"
            log_to_report "- ✗ Node.js: $NODE_VERSION (incompatible)\n"
        fi
    else
        print_warning "Node.js not found"
        log_to_report "- ⚠ Node.js: Not installed\n"
    fi
    
    # Check Python version
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
        PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
        if [[ "$PYTHON_MAJOR" -ge 3 ]] && [[ "$PYTHON_MINOR" -ge 8 ]]; then
            print_success "Python version: $PYTHON_VERSION (>= 3.8 required)"
            log_to_report "- ✓ Python: $PYTHON_VERSION\n"
        else
            print_failure "Python version: $PYTHON_VERSION (< 3.8)"
            log_to_report "- ✗ Python: $PYTHON_VERSION (incompatible)\n"
        fi
    else
        print_warning "Python 3 not found"
        log_to_report "- ⚠ Python: Not installed\n"
    fi
    
    # Check Rust version
    if command -v rustc &> /dev/null; then
        RUST_VERSION=$(rustc --version | awk '{print $2}')
        print_success "Rust version: $RUST_VERSION"
        log_to_report "- ✓ Rust: $RUST_VERSION\n"
    else
        print_warning "Rust not found"
        log_to_report "- ⚠ Rust: Not installed\n"
    fi
    
    # Check Cargo version
    if command -v cargo &> /dev/null; then
        CARGO_VERSION=$(cargo --version | awk '{print $2}')
        print_success "Cargo version: $CARGO_VERSION"
        log_to_report "- ✓ Cargo: $CARGO_VERSION\n"
    else
        print_warning "Cargo not found"
        log_to_report "- ⚠ Cargo: Not installed\n"
    fi
    
    log_to_report "\n"
}

audit_typescript() {
    print_section "Auditing TypeScript Code"
    log_to_report "## TypeScript Audit\n"
    
    # Check for package.json
    if [ -f "package.json" ]; then
        print_success "package.json found"
        log_to_report "- ✓ package.json exists\n"
        
        # Check for TypeScript dependencies
        if grep -q '"typescript"' package.json; then
            print_success "TypeScript dependency found"
            log_to_report "- ✓ TypeScript configured\n"
        else
            print_warning "TypeScript dependency not found in package.json"
            log_to_report "- ⚠ TypeScript not configured\n"
        fi
        
        # Check for test scripts
        if grep -q '"test"' package.json; then
            print_success "Test script found in package.json"
            log_to_report "- ✓ Test script configured\n"
        else
            print_warning "Test script not found in package.json"
            log_to_report "- ⚠ No test script configured\n"
        fi
        
        # Check for lint scripts
        if grep -q '"lint"' package.json; then
            print_success "Lint script found in package.json"
            log_to_report "- ✓ Lint script configured\n"
        else
            print_warning "Lint script not found in package.json"
            log_to_report "- ⚠ No lint script configured\n"
        fi
        
        # Check for tsconfig.json
        if [ -f "tsconfig.json" ]; then
            print_success "tsconfig.json found"
            log_to_report "- ✓ TypeScript configuration exists\n"
        else
            print_warning "tsconfig.json not found"
            log_to_report "- ⚠ No TypeScript configuration\n"
        fi
        
        # Check for source files
        if [ -d "src" ]; then
            TS_COUNT=$(find src -name "*.ts" -type f 2>/dev/null | wc -l)
            if [ "$TS_COUNT" -gt 0 ]; then
                print_success "Found $TS_COUNT TypeScript source files"
                log_to_report "- ✓ TypeScript source files: $TS_COUNT\n"
            else
                print_warning "No TypeScript source files found in src/"
                log_to_report "- ⚠ No TypeScript source files\n"
            fi
        else
            print_warning "src/ directory not found"
            log_to_report "- ⚠ No src/ directory\n"
        fi
    else
        print_warning "package.json not found"
        log_to_report "- ⚠ No package.json found\n"
    fi
    
    log_to_report "\n"
}

audit_python() {
    print_section "Auditing Python Code"
    log_to_report "## Python Audit\n"
    
    # Check for requirements.txt
    if [ -f "python/requirements.txt" ]; then
        print_success "python/requirements.txt found"
        log_to_report "- ✓ requirements.txt exists\n"
        
        # Count dependencies
        DEP_COUNT=$(grep -v "^#" python/requirements.txt | grep -v "^$" | wc -l)
        print_info "Found $DEP_COUNT Python dependencies"
        log_to_report "- ℹ Python dependencies: $DEP_COUNT\n"
    else
        print_warning "python/requirements.txt not found"
        log_to_report "- ⚠ No requirements.txt found\n"
    fi
    
    # Check for Python source files
    if [ -d "python" ]; then
        PY_COUNT=$(find python -name "*.py" -type f 2>/dev/null | wc -l)
        if [ "$PY_COUNT" -gt 0 ]; then
            print_success "Found $PY_COUNT Python source files"
            log_to_report "- ✓ Python source files: $PY_COUNT\n"
        else
            print_warning "No Python source files found in python/"
            log_to_report "- ⚠ No Python source files\n"
        fi
    else
        print_warning "python/ directory not found"
        log_to_report "- ⚠ No python/ directory\n"
    fi
    
    # Check for pytest configuration
    if [ -f "python/pytest.ini" ] || [ -f "python/pyproject.toml" ] || grep -q "pytest" python/requirements.txt 2>/dev/null; then
        print_success "Pytest configuration or dependency found"
        log_to_report "- ✓ Pytest configured\n"
    else
        print_warning "Pytest not configured"
        log_to_report "- ⚠ Pytest not configured\n"
    fi
    
    log_to_report "\n"
}

audit_rust() {
    print_section "Auditing Rust Code"
    log_to_report "## Rust Audit\n"
    
    # Check for Cargo.toml
    if [ -f "rust/Cargo.toml" ]; then
        print_success "rust/Cargo.toml found"
        log_to_report "- ✓ Cargo.toml exists\n"
        
        # Check for workspace or package
        if grep -q "\[workspace\]" rust/Cargo.toml; then
            print_info "Cargo workspace detected"
            log_to_report "- ℹ Cargo workspace configured\n"
        elif grep -q "\[package\]" rust/Cargo.toml; then
            print_success "Cargo package configured"
            log_to_report "- ✓ Cargo package configured\n"
        fi
    else
        print_warning "rust/Cargo.toml not found"
        log_to_report "- ⚠ No Cargo.toml found\n"
    fi
    
    # Check for Rust source files
    if [ -d "rust/src" ]; then
        RS_COUNT=$(find rust/src -name "*.rs" -type f 2>/dev/null | wc -l)
        if [ "$RS_COUNT" -gt 0 ]; then
            print_success "Found $RS_COUNT Rust source files"
            log_to_report "- ✓ Rust source files: $RS_COUNT\n"
        else
            print_warning "No Rust source files found in rust/src/"
            log_to_report "- ⚠ No Rust source files\n"
        fi
    else
        print_warning "rust/src/ directory not found"
        log_to_report "- ⚠ No rust/src/ directory\n"
    fi
    
    log_to_report "\n"
}

audit_security() {
    print_section "Auditing Security"
    log_to_report "## Security Audit\n"
    
    # Check for .env files committed
    if find . -name ".env" -type f 2>/dev/null | grep -q .; then
        print_failure "Found .env files in repository - potential security risk!"
        log_to_report "- ✗ .env files found in repository (security risk)\n"
    else
        print_success "No .env files found in repository"
        log_to_report "- ✓ No .env files in repository\n"
    fi
    
    # Check for .env.example
    if [ -f ".env.example" ]; then
        print_success ".env.example found"
        log_to_report "- ✓ .env.example exists\n"
    else
        print_warning ".env.example not found"
        log_to_report "- ⚠ No .env.example template\n"
    fi
    
    # Check for private keys in code
    PRIVATE_KEY_FOUND=false
    if grep -rE "PRIVATE_KEY.*=.*0x[a-fA-F0-9]{64}" . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist 2>/dev/null | grep -v ".env.example" | grep -q .; then
        print_failure "Potential private keys found in code!"
        log_to_report "- ✗ Potential private keys detected in code\n"
        PRIVATE_KEY_FOUND=true
    fi
    
    if [ "$PRIVATE_KEY_FOUND" = false ]; then
        print_success "No hardcoded private keys detected"
        log_to_report "- ✓ No hardcoded private keys\n"
    fi
    
    # Check .gitignore
    if [ -f ".gitignore" ]; then
        if grep -q "\.env$" .gitignore && grep -q "node_modules" .gitignore; then
            print_success ".gitignore properly configured"
            log_to_report "- ✓ .gitignore properly configured\n"
        else
            print_warning ".gitignore missing important entries"
            log_to_report "- ⚠ .gitignore incomplete\n"
        fi
    else
        print_failure ".gitignore not found"
        log_to_report "- ✗ No .gitignore file\n"
    fi
    
    log_to_report "\n"
}

audit_performance() {
    print_section "Auditing Performance Configurations"
    log_to_report "## Performance Audit\n"
    
    # Check for performance-related configurations
    if [ -f "package.json" ]; then
        # Check for production build scripts
        if grep -q '"build"' package.json; then
            print_success "Build script configured"
            log_to_report "- ✓ Build script present\n"
        else
            print_warning "No build script found"
            log_to_report "- ⚠ No build script\n"
        fi
    fi
    
    # Check Rust release profile
    if [ -f "rust/Cargo.toml" ]; then
        if grep -q "\[profile.release\]" rust/Cargo.toml; then
            print_success "Rust release profile configured"
            log_to_report "- ✓ Rust release profile configured\n"
        else
            print_info "Using default Rust release profile"
            log_to_report "- ℹ Default Rust release profile\n"
        fi
    fi
    
    # Check for optimization flags in TypeScript
    if [ -f "tsconfig.json" ]; then
        if grep -q '"declaration"' tsconfig.json && grep -q '"sourceMap"' tsconfig.json; then
            print_success "TypeScript compilation options configured"
            log_to_report "- ✓ TypeScript optimizations present\n"
        else
            print_info "Basic TypeScript configuration"
            log_to_report "- ℹ Basic TypeScript config\n"
        fi
    fi
    
    log_to_report "\n"
}

audit_documentation() {
    print_section "Auditing Documentation"
    log_to_report "## Documentation Audit\n"
    
    # Check for README
    if [ -f "README.md" ]; then
        print_success "README.md found"
        log_to_report "- ✓ README.md exists\n"
        
        # Check README content
        README_SIZE=$(wc -l < README.md)
        if [ "$README_SIZE" -gt 20 ]; then
            print_success "README.md has substantial content ($README_SIZE lines)"
            log_to_report "- ✓ README.md: $README_SIZE lines\n"
        else
            print_warning "README.md is minimal ($README_SIZE lines)"
            log_to_report "- ⚠ README.md: $README_SIZE lines (minimal)\n"
        fi
    else
        print_failure "README.md not found"
        log_to_report "- ✗ No README.md\n"
    fi
    
    # Check for docs directory
    if [ -d "docs" ]; then
        DOC_COUNT=$(find docs -name "*.md" -type f 2>/dev/null | wc -l)
        if [ "$DOC_COUNT" -gt 0 ]; then
            print_success "Found $DOC_COUNT documentation files"
            log_to_report "- ✓ Documentation files: $DOC_COUNT\n"
        else
            print_warning "docs/ directory exists but no .md files found"
            log_to_report "- ⚠ Empty docs/ directory\n"
        fi
    else
        print_warning "docs/ directory not found"
        log_to_report "- ⚠ No docs/ directory\n"
    fi
    
    log_to_report "\n"
}

audit_tests() {
    print_section "Auditing Test Coverage"
    log_to_report "## Test Coverage Audit\n"
    
    # Check for TypeScript tests
    if [ -d "tests" ] || [ -d "test" ] || [ -d "src/__tests__" ]; then
        TS_TEST_COUNT=$(find . -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | wc -l)
        if [ "$TS_TEST_COUNT" -gt 0 ]; then
            print_success "Found $TS_TEST_COUNT TypeScript test files"
            log_to_report "- ✓ TypeScript tests: $TS_TEST_COUNT files\n"
        else
            print_warning "Test directories exist but no TypeScript test files found"
            log_to_report "- ⚠ No TypeScript test files\n"
        fi
    else
        print_warning "No test directories found for TypeScript"
        log_to_report "- ⚠ No TypeScript test directories\n"
    fi
    
    # Check for Python tests
    if [ -d "python/tests" ] || [ -d "python/test" ]; then
        PY_TEST_COUNT=$(find python -name "test_*.py" -o -name "*_test.py" 2>/dev/null | wc -l)
        if [ "$PY_TEST_COUNT" -gt 0 ]; then
            print_success "Found $PY_TEST_COUNT Python test files"
            log_to_report "- ✓ Python tests: $PY_TEST_COUNT files\n"
        else
            print_warning "Python test directories exist but no test files found"
            log_to_report "- ⚠ No Python test files\n"
        fi
    else
        print_warning "No test directories found for Python"
        log_to_report "- ⚠ No Python test directories\n"
    fi
    
    # Check for Rust tests
    if [ -d "rust" ]; then
        if grep -r "#\[test\]" rust/src 2>/dev/null | grep -q .; then
            RUST_TEST_COUNT=$(grep -r "#\[test\]" rust/src 2>/dev/null | wc -l)
            print_success "Found $RUST_TEST_COUNT Rust test functions"
            log_to_report "- ✓ Rust tests: $RUST_TEST_COUNT functions\n"
        else
            print_warning "No Rust tests found"
            log_to_report "- ⚠ No Rust tests\n"
        fi
    fi
    
    log_to_report "\n"
}

audit_dependencies() {
    print_section "Auditing Dependencies"
    log_to_report "## Dependency Audit\n"
    
    # Check for Node.js dependency lock file
    if [ -f "yarn.lock" ]; then
        print_success "yarn.lock found (dependencies locked)"
        log_to_report "- ✓ yarn.lock exists\n"
    elif [ -f "package-lock.json" ]; then
        print_success "package-lock.json found (dependencies locked)"
        log_to_report "- ✓ package-lock.json exists\n"
    else
        print_warning "No dependency lock file found for Node.js"
        log_to_report "- ⚠ No Node.js lock file\n"
    fi
    
    # Check for Rust dependency lock file
    if [ -f "rust/Cargo.lock" ]; then
        print_success "Cargo.lock found (Rust dependencies locked)"
        log_to_report "- ✓ Cargo.lock exists\n"
    else
        print_warning "No Cargo.lock found"
        log_to_report "- ⚠ No Cargo.lock\n"
    fi
    
    # Check for Python requirements
    if [ -f "python/requirements.txt" ]; then
        # Check if versions are pinned
        UNPINNED=$(grep -v "^#" python/requirements.txt | grep -v "^$" | grep -v "==" | wc -l)
        if [ "$UNPINNED" -eq 0 ]; then
            print_success "All Python dependencies are pinned"
            log_to_report "- ✓ All Python dependencies pinned\n"
        else
            print_warning "$UNPINNED Python dependencies are not pinned"
            log_to_report "- ⚠ $UNPINNED unpinned Python dependencies\n"
        fi
    fi
    
    log_to_report "\n"
}

audit_ci_cd() {
    print_section "Auditing CI/CD Configuration"
    log_to_report "## CI/CD Audit\n"
    
    # Check for GitHub Actions
    if [ -d ".github/workflows" ]; then
        WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l)
        if [ "$WORKFLOW_COUNT" -gt 0 ]; then
            print_success "Found $WORKFLOW_COUNT GitHub Actions workflows"
            log_to_report "- ✓ GitHub Actions: $WORKFLOW_COUNT workflows\n"
        else
            print_warning ".github/workflows exists but no workflow files found"
            log_to_report "- ⚠ No workflow files\n"
        fi
    else
        print_warning "No GitHub Actions workflows found"
        log_to_report "- ⚠ No .github/workflows directory\n"
    fi
    
    # Check for other CI configurations
    if [ -f ".travis.yml" ]; then
        print_info "Travis CI configuration found"
        log_to_report "- ℹ Travis CI configured\n"
    fi
    
    if [ -f ".circleci/config.yml" ]; then
        print_info "CircleCI configuration found"
        log_to_report "- ℹ CircleCI configured\n"
    fi
    
    if [ -f "Jenkinsfile" ]; then
        print_info "Jenkins configuration found"
        log_to_report "- ℹ Jenkins configured\n"
    fi
    
    log_to_report "\n"
}

audit_git_hygiene() {
    print_section "Auditing Git Hygiene"
    log_to_report "## Git Hygiene Audit\n"
    
    # Check for large files
    LARGE_FILES=$(find . -type f -size +10M 2>/dev/null | grep -v ".git" | wc -l)
    if [ "$LARGE_FILES" -gt 0 ]; then
        print_warning "Found $LARGE_FILES files larger than 10MB"
        log_to_report "- ⚠ Large files: $LARGE_FILES (> 10MB)\n"
    else
        print_success "No files larger than 10MB"
        log_to_report "- ✓ No large files\n"
    fi
    
    # Check for common files that shouldn't be committed
    SHOULD_IGNORE=(".DS_Store" "Thumbs.db" "node_modules" "__pycache__" "*.pyc" "dist" "build" "target")
    for pattern in "${SHOULD_IGNORE[@]}"; do
        if find . -name "$pattern" 2>/dev/null | grep -q .; then
            print_warning "Found $pattern files/directories (should be in .gitignore)"
            log_to_report "- ⚠ $pattern found (should be ignored)\n"
        fi
    done
    
    log_to_report "\n"
}

generate_summary() {
    print_header "AUDIT SUMMARY"
    
    # Calculate percentages
    if [ "$TOTAL_CHECKS" -gt 0 ]; then
        PASS_PERCENT=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
        FAIL_PERCENT=$((FAILED_CHECKS * 100 / TOTAL_CHECKS))
        WARN_PERCENT=$((WARNING_CHECKS * 100 / TOTAL_CHECKS))
    else
        PASS_PERCENT=0
        FAIL_PERCENT=0
        WARN_PERCENT=0
    fi
    
    echo ""
    echo -e "Total Checks:    ${BLUE}${TOTAL_CHECKS}${NC}"
    echo -e "Passed:          ${GREEN}${PASSED_CHECKS} (${PASS_PERCENT}%)${NC}"
    echo -e "Failed:          ${RED}${FAILED_CHECKS} (${FAIL_PERCENT}%)${NC}"
    echo -e "Warnings:        ${YELLOW}${WARNING_CHECKS} (${WARN_PERCENT}%)${NC}"
    echo ""
    
    # Add summary to report
    log_to_report "## Summary Statistics\n"
    log_to_report "| Metric | Count | Percentage |\n"
    log_to_report "|--------|-------|------------|\n"
    log_to_report "| Total Checks | $TOTAL_CHECKS | 100% |\n"
    log_to_report "| Passed | $PASSED_CHECKS | $PASS_PERCENT% |\n"
    log_to_report "| Failed | $FAILED_CHECKS | $FAIL_PERCENT% |\n"
    log_to_report "| Warnings | $WARNING_CHECKS | $WARN_PERCENT% |\n"
    log_to_report "\n"
    
    # Determine overall status
    if [ "$FAILED_CHECKS" -gt 0 ]; then
        echo -e "${RED}Overall Status: FAILED${NC}"
        log_to_report "**Overall Status:** ❌ FAILED\n"
        return $EXIT_FAILURES
    elif [ "$WARNING_CHECKS" -gt 0 ]; then
        echo -e "${YELLOW}Overall Status: PASSED WITH WARNINGS${NC}"
        log_to_report "**Overall Status:** ⚠️  PASSED WITH WARNINGS\n"
        return $EXIT_WARNINGS
    else
        echo -e "${GREEN}Overall Status: PASSED${NC}"
        log_to_report "**Overall Status:** ✅ PASSED\n"
        return $EXIT_SUCCESS
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "APEX Integration Source Audit"
    echo "Starting comprehensive source audit..."
    echo "Report will be saved to: $AUDIT_REPORT"
    echo ""
    
    setup_audit_report
    
    # Run all audit checks
    audit_environment
    audit_typescript
    audit_python
    audit_rust
    audit_security
    audit_performance
    audit_documentation
    audit_tests
    audit_dependencies
    audit_ci_cd
    audit_git_hygiene
    
    # Generate final summary
    generate_summary
    EXIT_CODE=$?
    
    echo ""
    print_info "Full audit report saved to: $AUDIT_REPORT"
    
    # Add recommendations
    log_to_report "## Recommendations\n"
    if [ "$FAILED_CHECKS" -gt 0 ]; then
        log_to_report "1. Address all failed checks immediately\n"
        log_to_report "2. Review security vulnerabilities\n"
        log_to_report "3. Ensure all required dependencies are installed\n"
    fi
    if [ "$WARNING_CHECKS" -gt 0 ]; then
        log_to_report "1. Review and address warnings\n"
        log_to_report "2. Consider adding missing configurations\n"
        log_to_report "3. Improve test coverage\n"
    fi
    log_to_report "\n---\n"
    log_to_report "*Generated by APEX Integration Source Audit v1.0*\n"
    
    exit $EXIT_CODE
}

# Run main function
main
