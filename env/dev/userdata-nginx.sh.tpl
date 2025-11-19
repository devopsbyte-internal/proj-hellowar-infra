#!/usr/bin/env bash

set -euo pipefail



echo "[user_data] Starting backend bootstrap..." 

# Adjust this URL to your real GitHub raw URL
BOOTSTRAP_URL="${bootstrap_url}"

curl -fSL "$BOOTSTRAP_URL" -o /root/bootstrap-nginx.sh
chmod +x /root/bootstrap-nginx.sh

echo "[user_data] Running bootstrap script..."
/root/bootstrap-nginx.sh

sleep 1
echo "[user_data] Backend bootstrap completed."

