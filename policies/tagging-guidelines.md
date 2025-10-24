# Tagging Guidelines — Cost, Ownership & Governance

**Scope:** Applies to all AWS resources created by the *Resilient Web Tier (ALB + ASG)* design.  
**Purpose:** Enforce visibility, ownership, and cost governance across all environments.

---

## 🏷️ Standard Tags

| Key | Example Value | Purpose |
|-----|----------------|----------|
| `Project` | `elb-asg-blueprint` | Groups resources logically for billing & visibility |
| `Owner` | `naseeb` | Identifies accountable engineer or team |
| `Env` | `dev` / `staging` / `prod` | Clarifies environment type |
| `TTL` | `1h` / `24h` / `72h` | Time-to-live tag for auto-identifying stale resources |
| `CostCenter` | `training` / `portfolio` | Enables budget allocation and reporting |
| `ManagedBy` | `terraform` | Signals IaC ownership and automation scope |
| `Version` | `v1.0.0` | Links to release/version tracking in CI/CD |

---

## 📐 Tagging Rules

1. **Mandatory:** `Project`, `Owner`, and `Env` **must exist** on every resource.  
2. **Lifecycle Tags:**  
   - Use `TTL` for all test/dev resources.  
   - If not set → resource treated as “permanent”.
3. **Automation Tags:**  
   - Apply `ManagedBy=terraform` to all IaC-managed resources.  
   - Prevent manual drift by regularly validating tags (`terraform plan` / drift detection).
4. **Budget Control:**  
   - Group resources by `Project` tag in AWS Cost Explorer.  
   - Schedule periodic tag compliance reports (manual or automated later via CI/CD).
5. **Security/Compliance:**  
   - Tags must never include credentials, secrets, or personally identifiable data.  
   - Keys/values are alphanumeric, lowercase, and hyphenated.

---

## 🧰 Terraform Implementation

Tag injection pattern (already used in IaC):

```hcl
tags = merge(
  var.default_tags,
  {
    Name = "${var.project}-alb"
  }
)
```
**Example default_tags (from variables.tf):**
```hcl
variable "default_tags" {
  type = map(string)
  default = {
    Project = "elb-asg-blueprint"
    Owner   = "naseeb"
    TTL     = "1h"
    Env     = "dev"
  }
}
```

---

## 💰 Cost Governance Playbook

**Action	Frequency	Owner	Tool**

Review Cost by Tag	Weekly	Owner	AWS Cost Explorer
Detect Untagged Resources	Bi-weekly	Owner	AWS Config / Tag Editor
Cleanup TTL Expired	Monthly	Owner	Terraform destroy / scripts
Validate Drift (tags vs code)	Every commit	CI/CD (Phase-2)	GitHub Actions

---

## ✅ Compliance Checkpoints

- [ ] Every Terraform resource block includes tags.

- [ ] Default tags declared in one place (variables.tf).

- [ ] TTL defined for all test environments.

- [ ] Monthly review via Cost Explorer filters.

---

## 🧩 Notes

For production rollout, extend policy with DataClassification and Confidentiality tags.

CI/CD can enforce tagging compliance via terraform-compliance or tflint in Phase-2.
