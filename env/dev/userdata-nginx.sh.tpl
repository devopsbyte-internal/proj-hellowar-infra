#!/usr/bin/env bash

set -euo pipefail

echo "[user_data] Updating system..."
dnf -y update || yum -y update

echo "[user_data] Installing NGINX..."
dnf -y install nginx || yum -y install nginx

echo "[user_data] Enabling and starting NGINX..."
systemctl enable nginx
systemctl start nginx

echo "[user_data] Done (Nginx)"

