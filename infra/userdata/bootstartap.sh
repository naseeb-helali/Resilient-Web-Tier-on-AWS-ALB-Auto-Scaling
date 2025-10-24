#!/usr/bin/env bash
set -euxo pipefail

# Minimal bootstrap — static page + /health
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y || true
  apt-get install -y nginx || true
elif command -v yum >/dev/null 2>&1; then
  yum install -y nginx || true
  systemctl enable nginx || true
fi

mkdir -p /var/www/html
cat > /var/www/html/index.html <<'HTML'
<h1>It works</h1>
<p>Served by an ASG instance behind ALB.</p>
HTML

cat > /var/www/html/health <<'TXT'
ok
TXT

# Ensure Nginx running if available
if systemctl list-units --type=service | grep -qi nginx; then
  systemctl enable nginx
  systemctl restart nginx
fi
