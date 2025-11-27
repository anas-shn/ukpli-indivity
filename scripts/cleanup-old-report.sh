#!/bin/bash

# Keep only last 30 days of reports
find ../reports -name "*.html" -type f -mtime +30 -delete
find ../reports -name "*.xml" -type f -mtime +30 -delete
find ../logs -name "*.log" -type f -mtime +30 -delete

echo "✅ Old reports cleaned up"
