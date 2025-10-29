#!/bin/bash

################################################################################
# APEX Quick Pre-Commit Validation Script
# 
# This script performs essential checks before committing code.
# Run this before every commit to catch common issues early.
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_failure() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

CHECKS_FAILED=0

quick_security_check() {
    print_section "Security Quick Check"
    
    # Check for .env files
    if git diff --cached --name-only | grep -q "^\.env$"; then
        print_failure ".env file is staged - DO NOT COMMIT!"
        ((CHECKS_FAILED++))
    else
        print_success "No .env files staged"
    fi
    
    # Check for private keys in staged changes
    if git diff --cached | grep -iE "(PRIVATE_KEY.*=.*0x[a-fA-F0-9]{64}|BEGIN PRIVATE KEY|BEGIN RSA PRIVATE KEY)" | grep -qv ".env.example"; then
        print_failure "Potential private keys detected in staged changes!"
        ((CHECKS_FAILED++))
    else
        print_success "No private keys detected in staged changes"
    fi
    
    # Check for API keys
    if git diff --cached | grep -iE "(API_KEY|SECRET_KEY|ACCESS_TOKEN).*=.*[a-zA-Z0-9]{20,}" | grep -qv ".env.example"; then
        print_warning "Potential API keys detected - verify they are templates"
    fi
}

quick_lint_check() {
    print_section "Quick Lint Check"
    
    # TypeScript/JavaScript
    if [ -f "package.json" ] && command -v npm &> /dev/null; then
        if grep -q '"lint"' package.json; then
            print_info "Running TypeScript linter..."
            if npm run lint --silent > /dev/null 2>&1; then
                print_success "TypeScript lint passed"
            else
                print_warning "TypeScript lint issues found (not blocking)"
            fi
        fi
    fi
    
    # Python
    if [ -d "python" ] && command -v flake8 &> /dev/null; then
        print_info "Running Python linter..."
        if flake8 python/ --count --select=E9,F63,F7,F82 --show-source --statistics > /dev/null 2>&1; then
            print_success "Python lint passed"
        else
            print_warning "Python lint issues found (not blocking)"
        fi
    fi
}

quick_format_check() {
    print_section "Code Format Check"
    
    # Check for TypeScript formatting
    if [ -f "package.json" ] && grep -q "prettier" package.json 2>/dev/null; then
        if command -v npx &> /dev/null; then
            print_info "Checking TypeScript formatting..."
            if npx prettier --check "src/**/*.ts" > /dev/null 2>&1; then
                print_success "TypeScript formatting is correct"
            else
                print_warning "TypeScript formatting issues (run: npm run format)"
            fi
        fi
    fi
}

check_file_sizes() {
    print_section "File Size Check"
    
    # Check for large files being staged
    LARGE_FILES=$(git diff --cached --name-only | xargs -I {} du -k "{}" 2>/dev/null | awk '$1 > 1024 {print $2}')
    
    if [ -n "$LARGE_FILES" ]; then
        print_warning "Large files detected (>1MB):"
        echo "$LARGE_FILES" | while read -r file; do
            SIZE=$(du -h "$file" | cut -f1)
            echo "  - $file ($SIZE)"
        done
        print_info "Consider using Git LFS for large files"
    else
        print_success "No large files detected"
    fi
}

check_test_files() {
    print_section "Test Files Check"
    
    # Check if source files changed but no test files
    SRC_CHANGED=$(git diff --cached --name-only | grep -E "\.(ts|js|py|rs)$" | grep -v "test" | grep -v "spec" | wc -l)
    TEST_CHANGED=$(git diff --cached --name-only | grep -E "(test|spec)\.(ts|js|py|rs)$" | wc -l)
    
    if [ "$SRC_CHANGED" -gt 0 ] && [ "$TEST_CHANGED" -eq 0 ]; then
        print_warning "Source files changed but no test files updated"
        print_info "Consider adding or updating tests"
    elif [ "$TEST_CHANGED" -gt 0 ]; then
        print_success "Test files included in commit"
    fi
}

check_commit_message() {
    print_section "Commit Message Guidelines"
    
    print_info "Good commit message format:"
    echo "  Type: Brief description (50 chars max)"
    echo ""
    echo "  Types: feat, fix, docs, style, refactor, test, chore"
    echo "  Example: feat: Add ML-based opportunity scoring"
}

check_documentation() {
    print_section "Documentation Check"
    
    # Check if code files changed but no documentation updates
    CODE_CHANGED=$(git diff --cached --name-only | grep -E "\.(ts|js|py|rs)$" | wc -l)
    DOCS_CHANGED=$(git diff --cached --name-only | grep -E "\.md$" | wc -l)
    
    if [ "$CODE_CHANGED" -gt 5 ] && [ "$DOCS_CHANGED" -eq 0 ]; then
        print_warning "Significant code changes but no documentation updates"
        print_info "Consider updating relevant documentation"
    fi
}

main() {
    print_header "APEX Pre-Commit Validation"
    
    # Check if there are staged changes
    if ! git diff --cached --quiet; then
        print_info "Validating staged changes..."
        
        quick_security_check
        quick_lint_check
        quick_format_check
        check_file_sizes
        check_test_files
        check_documentation
        check_commit_message
        
        echo ""
        print_header "VALIDATION SUMMARY"
        
        if [ "$CHECKS_FAILED" -eq 0 ]; then
            echo ""
            print_success "All critical checks passed! ✨"
            echo ""
            print_info "You're ready to commit. Run: git commit -m 'Your message'"
            exit 0
        else
            echo ""
            print_failure "$CHECKS_FAILED critical check(s) failed!"
            echo ""
            print_info "Please fix the issues above before committing."
            exit 1
        fi
    else
        print_warning "No staged changes found"
        print_info "Stage your changes with: git add <files>"
        exit 1
    fi
}

main
