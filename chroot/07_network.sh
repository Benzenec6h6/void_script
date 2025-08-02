#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Configuring network with $NETMGR"

# Helper: enable a runit service safely
enable_service() {
  local svc="$1"
  if [ -z "$svc" ]; then
    echo "[!] Error: service name is empty"
    return 1
  fi

  if [ ! -e "/etc/sv/$svc" ]; then
    echo "[!] Service directory /etc/sv/$svc not found"
    return 1
  fi

  if [ ! -e "/etc/runit/runsvdir/default/$svc" ]; then
    ln -s "/etc/sv/$svc" "/etc/runit/runsvdir/default/$svc"
    echo "[i] Service $svc enabled"
  else
    echo "[i] Service $svc already enabled"
  fi
}

disable_service() {
  local svc="$1"
  if [ -L "/etc/runit/runsvdir/default/$svc" ]; then
    rm "/etc/runit/runsvdir/default/$svc"
    echo "[i] Service $svc disabled"
  else
    echo "[i] Service $svc is not enabled"
  fi
}

case "$NETMGR" in
  dhcpcd)
    # xbps-install -y dhcpcd
    enable_service dhcpcd
    disable_service iwd
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
