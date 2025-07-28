#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Configuring network with $NETMGR"

case "$NETMGR" in
  dhcpcd)
    xbps-install -y dhcpcd
    ln -s /etc/sv/dhcpcd /var/service/
    ;;
  iwd)
    xbps-install -y iwd
    ln -s /etc/sv/iwd /var/service/
    ;;
  *)
    echo "[!] Unknown network manager: $NETMGR"
    exit 1
    ;;
esac