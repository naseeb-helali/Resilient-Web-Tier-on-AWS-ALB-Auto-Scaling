#!/usr/bin/env bash
# Purpose: Verify that the test app exposes /health returning 200 OK (when user_data is executed).
# Usage: Run inside a VM/container where bootstrap.sh has been executed.
set -euo pipefail

URL="${1:-http://localhost/health}"

echo "[tests] Checking health endpoint at: ${URL}"
status_code=$(curl -s -o /tmp/health.out -w "%{http_code}" "${URL}" || true)

if [[ "${status_code}" == "200" ]] && grep -qi "ok" /tmp/health.out; then
  echo "[tests] Health OK (200 + body contains 'ok')"
  exit 0
else
  echo "[tests] Health FAIL (status=${status_code})"
  echo "------- Response body -------"
  cat /tmp/health.out || true
  echo "-----------------------------"
  exit 1
fi
