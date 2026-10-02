#!/bin/bash
# =============================================================================
# health-check.sh — Container Health Check Script
# =============================================================================
# This script verifies that the web application is responding correctly.
# It is used in two places:
#   1. Dockerfile HEALTHCHECK — Docker/ECS checks container health
#   2. GitHub Actions — Post-deployment verification step
#
# Exit code 0 = healthy (app is responding with HTTP 200)
# Exit code 1 = unhealthy (app is not responding or returning errors)
#
# COMPARISON WITH ORIGINAL PROJECT:
# The original project relied on CodeDeploy's ValidateService lifecycle
# hook and manual browser verification. This script automates that check.
# =============================================================================

# The URL to check — defaults to localhost:8080 (Tomcat's default port)
# Can be overridden by passing a URL as the first argument
URL="${1:-http://localhost:8080/}"

# Maximum number of retry attempts before giving up
MAX_RETRIES=5

# Seconds to wait between retry attempts
RETRY_INTERVAL=10

echo "Health check: Testing application at ${URL}"
echo "Will retry up to ${MAX_RETRIES} times with ${RETRY_INTERVAL}s intervals"

# Loop through retry attempts
for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt ${i}/${MAX_RETRIES}..."

    # curl flags explained:
    #   -f  = fail silently on HTTP errors (returns exit code 22)
    #   -s  = silent mode (no progress bar)
    #   -o  = write output to /dev/null (we only care about the exit code)
    #   -w  = write out the HTTP status code after the request
    HTTP_CODE=$(curl -f -s -o /dev/null -w "%{http_code}" "${URL}" 2>/dev/null)
    CURL_EXIT=$?

    if [ $CURL_EXIT -eq 0 ] && [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Health check PASSED — HTTP ${HTTP_CODE}"
        exit 0
    fi

    echo "❌ Attempt ${i} failed (HTTP: ${HTTP_CODE}, curl exit: ${CURL_EXIT})"

    # Don't sleep after the last attempt
    if [ $i -lt $MAX_RETRIES ]; then
        echo "Waiting ${RETRY_INTERVAL}s before next attempt..."
        sleep $RETRY_INTERVAL
    fi
done

echo "💀 Health check FAILED after ${MAX_RETRIES} attempts"
exit 1

