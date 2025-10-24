# Makefile — Resilient Web Tier (ALB + ASG) — Phase-1
# Purpose: Unify IaC validation, static tests, and cleanup under one command set.

SHELL := /bin/bash

# Variables
INFRA_DIR := infra
TFVARS := $(INFRA_DIR)/examples/terraform.tfvars.example
TEST_DIR := tests

# === Terraform ===
fmt:
	@echo "[make] Formatting Terraform files..."
	cd $(INFRA_DIR) && terraform fmt -recursive

validate:
	@echo "[make] Validating Terraform syntax..."
	cd $(INFRA_DIR) && terraform validate

plan:
	@echo "[make] Running dry plan (no apply)..."
	cd $(INFRA_DIR) && terraform plan -var-file=$(TFVARS) -out=/tmp/tfplan

graph:
	@echo "[make] Generating dependency graph..."
	cd $(INFRA_DIR) && terraform graph | dot -Tpng > tf-graph.png
	@echo "[make] Graph generated: tf-graph.png"

# === Tests ===
test-static:
	@echo "[make] Running static health contract checks..."
	./$(TEST_DIR)/static-health-contract.sh

test-iac:
	@echo "[make] Running IaC sanity checks..."
	./$(TEST_DIR)/iac-sanity.sh $(TFVARS)

test-runtime:
	@echo "[make] Running runtime health probe (if local VM available)..."
	./$(TEST_DIR)/health-endpoint-check.sh http://localhost/health

test-all: fmt validate test-static test-iac
	@echo "[make] ✅ All tests completed successfully (plan-only phase)."

# === Cleanup ===
clean:
	@echo "[make] Cleaning temporary files..."
	rm -f tf-graph.png /tmp/tfplan || true
	@echo "[make] Cleanup done."

# === Help ===
help:
	@echo ""
	@echo "Available targets:"
	@echo "  make fmt            - Format Terraform code"
	@echo "  make validate       - Validate Terraform configuration"
	@echo "  make plan           - Dry-run Terraform plan (no cost)"
	@echo "  make graph          - Generate Terraform dependency graph"
	@echo "  make test-static    - Run static contract checks"
	@echo "  make test-iac       - Validate IaC plan-only"
	@echo "  make test-runtime   - Probe /health endpoint (optional)"
	@echo "  make test-all       - Run all tests except runtime"
	@echo "  make clean          - Remove temporary files"
	@echo ""
