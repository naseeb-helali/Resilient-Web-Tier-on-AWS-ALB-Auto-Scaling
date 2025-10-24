# Runbook: Unhealthy Targets Detected in Target Group

**Service:** Web Tier (ALB + ASG)  
**Severity:** Medium → may escalate if all targets become unhealthy

---

## 🔎 Symptoms
- CloudWatch metric `UnHealthyHostCount` rising.
- ALB dashboard shows targets as "unhealthy".
- Increased 5xx errors or slow responses observed.

---

## 🧭 Diagnosis Steps
1. **Check health endpoint locally (if possible):**
   ```bash
   curl -v http://<instance-ip>/health
   ```
   #### Expected output: HTTP 200 + body contains ok.

**2. Review Target Group health configuration:**

Path = /health

Matcher = 200–399

Interval = 15s, Timeout = 5s



**3. Verify security group rules:**

ASG SG must allow 80/tcp from ALB SG only.



**4. Review bootstrap or app logs (if deployed):**

Ensure bootstrap.sh completes successfully.

Confirm web server process is running.

---

## 🧰 Actions

Restart instance (if app not responding).

Verify Nginx/HTTPD service status.

Check if ALB health check path is misconfigured.

Increase grace_period if bootstrap takes long.

---

## ✅ Verification

Metric HealthyHostCount stable > 0.

ALB console: all targets show "healthy".

No recent 5xx spikes in ALB metrics.
