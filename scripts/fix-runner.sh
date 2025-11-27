#!/bin/bash

# ============================================================
# Quick Fix Script untuk GitHub Actions Runner
# Run this on your runner server to fix common issues
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_header "GitHub Actions Runner - Quick Fix"
echo ""

# ============================================================
# Step 1: Check Newman Installation
# ============================================================
print_header "Step 1: Checking Newman Installation"

if command -v newman &> /dev/null; then
    print_success "Newman installed: $(newman --version)"
else
    print_error "Newman not found!"
    print_info "Installing Newman..."
    sudo npm install -g newman newman-reporter-htmlextra newman-reporter-junit
    print_success "Newman installed"
fi

# ============================================================
# Step 2: Find Runner Work Directory
# ============================================================
print_header "Step 2: Locating Runner Work Directory"

RUNNER_WORK_DIR="$HOME/actions-runner/_work/ukpli-indivity/ukpli-indivity"

if [ -d "$RUNNER_WORK_DIR" ]; then
    print_success "Work directory found: $RUNNER_WORK_DIR"
else
    print_info "Work directory not found. It will be created on first run."
    print_info "Expected location: $RUNNER_WORK_DIR"
fi

# ============================================================
# Step 3: Check Collection File
# ============================================================
print_header "Step 3: Checking Collection File"

if [ -d "$RUNNER_WORK_DIR" ]; then
    cd "$RUNNER_WORK_DIR"
    
    if [ -f "collections/API_BPS_Complete_with_negative_tests.json" ]; then
        print_success "Collection file found!"
        FILE_SIZE=$(du -h "collections/API_BPS_Complete_with_negative_tests.json" | cut -f1)
        print_info "File size: $FILE_SIZE"
    else
        print_error "Collection file NOT found!"
        print_info "Please add it to your repository:"
        echo ""
        echo "  mkdir -p collections"
        echo "  cp API_BPS_Complete_with_negative_tests.json collections/"
        echo "  git add collections/"
        echo "  git commit -m 'add: API collection'"
        echo "  git push"
        echo ""
    fi
else
    print_info "Runner work directory not created yet."
    print_info "It will be created on first workflow run."
fi

# ============================================================
# Step 4: Test Manual Run (if collection exists)
# ============================================================
if [ -f "$RUNNER_WORK_DIR/collections/API_BPS_Complete_with_negative_tests.json" ]; then
    print_header "Step 4: Testing Manual Run"
    
    read -p "Do you want to test Newman manually? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$RUNNER_WORK_DIR"
        
        read -p "Enter BPS_API_KEY: " api_key
        read -p "Enter DOMAIN_VALUE (default 7315): " domain
        domain=${domain:-7315}
        
        mkdir -p reports logs
        
        print_info "Running test..."
        newman run collections/API_BPS_Complete_with_negative_tests.json \
            --env-var "API_KEY=$api_key" \
            --env-var "DOMAIN_VALUE=$domain" \
            --reporters cli \
            --timeout-request 10000
        
        if [ $? -eq 0 ]; then
            print_success "Manual test passed!"
        else
            print_error "Manual test failed. Check the error above."
        fi
    fi
fi

# ============================================================
# Step 5: Check Runner Service
# ============================================================
print_header "Step 5: Checking Runner Service"

if systemctl is-active --quiet actions.runner.*; then
    print_success "Runner service is running"
    
    # Get runner status
    RUNNER_STATUS=$(systemctl status actions.runner.* | grep "Active:" | awk '{print $2}')
    print_info "Status: $RUNNER_STATUS"
else
    print_error "Runner service is NOT running!"
    print_info "Start it with:"
    echo "  cd ~/actions-runner"
    echo "  sudo ./svc.sh start"
fi

# ============================================================
# Step 6: Verify Runner Connection
# ============================================================
print_header "Step 6: Verifying Runner Connection"

print_info "Check runner status at:"
echo "  https://github.com/anas-shn/ukpli-indivity/settings/actions/runners"
echo ""
print_info "Runner should show 'Idle' status"

# ============================================================
# Summary
# ============================================================
print_header "Summary & Next Steps"

echo ""
echo "✅ Checklist:"
echo ""

if command -v newman &> /dev/null; then
    echo "  ✅ Newman installed"
else
    echo "  ❌ Newman NOT installed"
fi

if [ -d "$RUNNER_WORK_DIR" ]; then
    echo "  ✅ Work directory exists"
else
    echo "  ⚠️  Work directory will be created on first run"
fi

if [ -f "$RUNNER_WORK_DIR/collections/API_BPS_Complete_with_negative_tests.json" ]; then
    echo "  ✅ Collection file exists"
else
    echo "  ❌ Collection file NOT found - add to repository!"
fi

if systemctl is-active --quiet actions.runner.*; then
    echo "  ✅ Runner service is running"
else
    echo "  ❌ Runner service NOT running"
fi

echo ""
print_info "Next Steps:"
echo ""
echo "1. Add collection to repository if not exists:"
echo "   git add collections/API_BPS_Complete_with_negative_tests.json"
echo "   git commit -m 'add: collection'"
echo "   git push"
echo ""
echo "2. Update workflow file (use newman-tests-fixed.yml)"
echo ""
echo "3. Push to trigger workflow:"
echo "   git push origin main"
echo ""
echo "4. Monitor at:"
echo "   https://github.com/anas-shn/ukpli-indivity/actions"
echo ""

print_header "Done!"
