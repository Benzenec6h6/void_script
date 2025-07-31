#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Configuring network with $NETMGR"

# Helper: enable a runit service safely
enable_service() {
  local svc="$1"
  if [ ! -e "/var/service/$svc" ]; then
    ln -s "/etc/sv/$svc" "/var/service/"
  else
    echo "[i] Service $svc already enabled"
  fi
}

# Helper: disable a runit service safely
disable_service() {
  local svc="$1"
  if [ -L "/var/service/$svc" ]; then
    rm "/var/service/$svc"
    echo "[i] Service $svc disabled"
  fi
}

case "$NETMGR" in
  dhcpcd)
    echo "dhcpcd is already enabled"
    #xbps-install -y dhcpcd
    enable_service dhcpcd
    #disable_service iwd
    ;;
  iwd)
    xbps-install -y iwd
    enable_service iwd
    disable_service dhcpcd
    ;;
  *)
    echo "[!] Unknown network manager: $NETMGR"
    exit 1
    ;;
esac
