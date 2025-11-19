#!/usr/bin/env bash
set -euo pipefail

echo "[user_data] Updating system..."
dnf -y update || yum -y update

echo "[user_data] Installing NGINX..."
dnf -y install nginx || yum -y install nginx

# ---- Basic OS-level hardening for NGINX files ----
echo "[user_data] Setting secure umask for future shells..."
cat > /etc/profile.d/nginx-umask.sh << 'EOF'
# Default umask for interactive shells (doesn't affect existing files)
/bin/umask 0027
EOF

# App docroot lives outside default /usr/share/nginx/html
APP_ROOT="/srv/hellowar"

echo "[user_data] Creating application docroot at ${APP_ROOT}..."
mkdir -p "${APP_ROOT}"

# Ensure nginx user exists (should already exist from package, but safe to check)
if ! id nginx >/dev/null 2>&1; then
  useradd --system --no-create-home --shell /sbin/nologin nginx
fi

echo "[user_data] Setting ownership and permissions..."
chown -R nginx:nginx "${APP_ROOT}"
chmod 0750 "${APP_ROOT}"

# ---- NGINX config hardening / cleanup ----
echo "[user_data] Disabling default server config if present..."
if [ -f /etc/nginx/conf.d/default.conf ]; then
  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
fi

echo "[user_data] Creating hellowar frontend server block..."
cat > /etc/nginx/conf.d/hellowar.conf << 'EOF'
server {
    listen       80 default_server;
    listen       [::]:80 default_server;

    server_name  _;

    # Our app docroot
    root   /srv/hellowar;
    index  index.html;

    # Basic security headers (tweak as needed)
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Restrict access to nginx status/example locations (none enabled by default)
}
EOF

# ---- Placeholder app content ----
echo "[user_data] Writing placeholder index.html..."
cat > "${APP_ROOT}/index.html" << 'HTML'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Hello WAR Frontend - Placeholder</title>
  </head>
  <body>
    <h1>Hello WAR Frontend</h1>
    <p>NGINX is up and serving from /srv/hellowar</p>
    <p>CI/CD will later deploy the React dist here.</p>
  </body>
</html>
HTML

chown nginx:nginx "${APP_ROOT}/index.html"
chmod 0640 "${APP_ROOT}/index.html"

# ---- Systemd service hardening (similar spirit to Tomcat) ----
# DO NOT OVERWRITE /systemd/system/nginx.service (package upgrades can overwrite it later)
# Override/Extend : /systemd/system/<service>.service.d/<custom>.conf
# Systemd will load the unit file in this order:
# /usr/lib/systemd/system/nginx.service ← packaged file
# /etc/systemd/system/nginx.service.d/*.conf ← YOUR overrides
# Merge them

echo "[user_data] Adding systemd hardening overrides for NGINX..."
mkdir -p /etc/systemd/system/nginx.service.d

cat > /etc/systemd/system/nginx.service.d/hardening.conf << 'EOF'
[Service]
UMask=0027
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=full
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
EOF

echo "[user_data] Enabling and restarting NGINX..."
systemctl daemon-reload
systemctl enable nginx
systemctl restart nginx

echo "[user_data] Done (NGINX frontend hardened-ish)."
