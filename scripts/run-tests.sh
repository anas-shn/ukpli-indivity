#!/bin/bash

# Configuration
COLLECTION_FILE="../collections/API_BPS_Complete_with_negative_tests.json"
REPORT_DIR="../reports"
LOG_DIR="../logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Load environment variables
if [ -f ../.env ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
fi

# Create directories
mkdir -p $REPORT_DIR $LOG_DIR

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  BPS API Testing - Newman Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run Newman
echo -e "${GREEN}Running tests...${NC}"

newman run $COLLECTION_FILE \
    --env-var "API_KEY=$BPS_API_KEY" \
    --env-var "DOMAIN_VALUE=$BPS_DOMAIN" \
    --reporters cli,htmlextra,junit \
    --reporter-htmlextra-export "$REPORT_DIR/test-report-$TIMESTAMP.html" \
    --reporter-htmlextra-title "BPS API Test Report - $TIMESTAMP" \
    --reporter-junit-export "$REPORT_DIR/junit-report-$TIMESTAMP.xml" \
    --delay-request 500 \
    --timeout-request 10000 \
    2>&1 | tee "$LOG_DIR/test-log-$TIMESTAMP.log"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Tests completed successfully!${NC}"
else
    echo -e "${RED}❌ Tests failed with exit code: $EXIT_CODE${NC}"
fi

echo ""
echo -e "${BLUE}Reports saved to: $REPORT_DIR${NC}"
echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}"

exit $EXIT_CODE
