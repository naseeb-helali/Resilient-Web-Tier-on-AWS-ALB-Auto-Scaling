# Runbook: Cost Teardown Checklist

**Purpose:** Prevent orphaned or idle resources after test or training phases.

---

## 🔎 When to Use
- After completing plan/apply tests (Phase-2 and beyond).
- When switching environments (dev → staging).

---

## 🧭 Checklist
1. **Destroy IaC resources safely:**
   ```bash
   cd infra && terraform destroy -auto-approve
   ```
**2. Verify all ALB/ASG/TG removed:**

aws elbv2 describe-load-balancers

aws autoscaling describe-auto-scaling-groups


**3. Delete test ACM certificates if unused.**

**4. Clean up CloudWatch logs and S3 buckets (if enabled).**

**5. Confirm no active EC2 instances remain.**

**6. Tag future test resources with TTL=1h to ensure auto-flagging.**

---

## ✅ Verification

**AWS Console → no active resources under project tag.**

**Billing dashboard shows no cost spikes.**
