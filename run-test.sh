#!/bin/bash

set -e

COLLECTION="./collections/api-bps.json"
ENVIRONMENT="./environments/env.json"
REPORT_DIR="./reports"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
REPORT_HTML="$REPORT_DIR/report-$TIMESTAMP.html"

mkdir -p $REPORT_DIR

echo "=== Running Newman Tests ==="
newman run "$COLLECTION" \
  -e "$ENVIRONMENT" \
  --timeout-request 30000 \
  --reporters cli,html \
  --reporter-html-export "$REPORT_HTML"

EXIT_CODE=$?

echo "Report saved to: $REPORT_HTML"
echo "Newman exit code: $EXIT_CODE"

exit $EXIT_CODE
