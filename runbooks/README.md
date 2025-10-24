Operational playbooks for the **Resilient Web Tier (ALB + ASG)**.

## Available Runbooks
| File | Purpose |
|------|----------|
| `incident-unhealthy-targets.md` | Handle health check failures / UnHealthyHostCount spikes |
| `incident-5xx-spike.md` | Mitigate backend 5xx response spikes |
| `cost-teardown-checklist.md` | Ensure safe teardown and cost control after tests |

## Usage
These runbooks guide manual intervention in Phase-1 (plan-only).  
In Phase-2, they will serve as the basis for **automated CI/CD remediation and alerts** (via GitHub Actions + CloudWatch alarms).
