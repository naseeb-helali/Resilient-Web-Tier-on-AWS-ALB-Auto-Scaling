# Runbook: 5xx Error Spike on ALB

**Service:** Web Tier (ALB + ASG)  
**Severity:** High if persistent > 5min

---

## 🔎 Symptoms
- CloudWatch metric `HTTPCode_ELB_5XX_Count` spiking.
- Users report intermittent errors or blank pages.
- Access logs (if enabled) show 502/504.

---

## 🧭 Diagnosis Steps
1. **Identify the source:**
   - 502 → backend closed connection or invalid response.
   - 504 → timeout waiting for response from target.

2. **Check Target Group health:**
   - Are targets `healthy` or `unhealthy`?
   - Health path `/health` must return quickly (<2s).

3. **Confirm Security Group/NACL not blocking responses.**
4. **If app runs locally:** review server logs for timeouts.

---

## 🧰 Actions
- Restart unhealthy targets (via ASG terminate-relaunch).
- Temporarily route to fixed-response 200 page:
  ```hcl
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Temporary maintenance"
      status_code  = "200"
    }
  }
  ```
  - Adjust idle_timeout if long requests are normal (e.g., increase from 60 → 120).

---

## ✅ Verification

- 5xx metrics drop to normal baseline.

- ALB access logs show 200–399 responses predominantly.

- End-user tests return stable, fast responses.
