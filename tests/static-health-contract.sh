#!/usr/bin/env bash
# Purpose: Static contract checks for health configuration in IaC and user_data.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN_TF="${ROOT_DIR}/infra/main.tf"
BOOTSTRAP="${ROOT_DIR}/infra/user_data/bootstrap.sh"

echo "[static] Verifying health contract in ${MAIN_TF} ..."
grep -q 'path *= *"/health"' "${MAIN_TF}"            || { echo "[static] Missing health path"; exit 1; }
grep -q 'matcher *= *"200-399"' "${MAIN_TF}"          || { echo "[static] Missing matcher 200-399"; exit 1; }
grep -q 'deregistration_delay *= *300' "${MAIN_TF}"   || { echo "[static] Missing deregistration_delay=300"; exit 1; }

echo "[static] Verifying bootstrap writes /health ..."
grep -q '/var/www/html/health' "${BOOTSTRAP}"         || { echo "[static] bootstrap does not create /health"; exit 1; }

echo "[static] OK"
