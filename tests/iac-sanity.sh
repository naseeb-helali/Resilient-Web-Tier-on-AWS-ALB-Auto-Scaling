#!/usr/bin/env bash
# Purpose: Sanity checks for Terraform (fmt/validate/plan) without applying.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}/infra"

echo "[iac] terraform fmt (check only)"
terraform fmt -recursive -check

echo "[iac] terraform validate"
terraform validate

echo "[iac] terraform plan (dry-run)"
# You can pass a tfvars file as first argument, or fallback to example.
TFVARS="${1:-examples/terraform.tfvars.example}"
terraform plan -var-file="${TFVARS}" -out=/tmp/tfplan >/dev/null

echo "[iac] OK"
