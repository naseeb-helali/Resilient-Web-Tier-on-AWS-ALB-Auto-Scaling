# Tests

This folder hosts minimal, zero-cost checks to enforce the web-tier health contract before any real deployment.

## Scripts
- `health-endpoint-check.sh` — runtime probe (expects `/health` to return `200` with body containing `ok`).  
  _Use only if you executed `infra/user_data/bootstrap.sh` inside a VM/container._

- `static-health-contract.sh` — static checks ensuring IaC and `bootstrap.sh` match the agreed health contract (`/health`, `200–399`, `deregistration_delay=300`).

- `iac-sanity.sh` — runs `terraform fmt -check`, `validate`, and a dry `plan` (no apply).

## Usage
```bash
# Static contract checks
./tests/static-health-contract.sh

# IaC sanity (dry plan)
./tests/iac-sanity.sh infra/examples/terraform.tfvars.example

# Runtime health probe (only inside a VM/container where user_data ran)
./tests/health-endpoint-check.sh http://localhost/health
