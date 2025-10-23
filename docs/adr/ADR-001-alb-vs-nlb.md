# ADR-001: Choosing ALB for the Web Tier

- **Status:** Accepted
- **Context:** The web tier requires HTTP/HTTPS, content-based routing (host/path), TLS offloading, health-aware traffic, and tight integration with Auto Scaling.
- **Decision:** Use **Application Load Balancer (ALB)** for the web tier in Phase-1.
- **Rationale:**
  - Native Layer-7 (HTTP/HTTPS) features: host/path routing, redirects, fixed responses, auth actions.
  - Cross-Zone enabled by default simplifies distribution and improves availability.
  - Tight integration with Target Groups and HTTP health checks.
  - TLS offloading via ACM + SNI for multi-cert support.
- **Alternatives:**
  - **NLB:** Best for TCP/UDP, ultra-low latency, static IPs—does not provide L7 routing needed here.
  - **GWLB:** Suited to security appliances (GENEVE). Out of scope for the web tier.
- **Consequences:**
  - Public ALB in ≥2 AZ public subnets; ASG in private subnets.
  - TG health check at `/health` (200–399). Optional stickiness if required.
  - Security boundary enforced by SGs (ALB SG → ASG SG).
- **NFR Alignment:**
  - HA (multi-AZ ALB), Resilience (health + deregistration delay), Security (SG boundary), Observability (metrics/logs).
