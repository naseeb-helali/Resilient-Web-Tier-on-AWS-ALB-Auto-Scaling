# Infrastructure (Terraform) — Phase-1 (Plan-Only)

This folder contains the IaC for the web tier:
- ALB + Target Group + Listeners (HTTP always; optional HTTPS if `acm_certificate_arn` is provided)
- Security Groups: ALB SG and ASG SG (least-privilege boundary)
- Launch Template + Auto Scaling Group (HTTP health-aware)

> **Phase-1 is plan-only** to avoid costs. No `apply` in this phase.

## Commands
```bash
cd infra
terraform fmt -recursive
terraform validate
