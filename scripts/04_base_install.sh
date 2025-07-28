#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Setting up musl repository config..."
mkdir -p /mnt/etc/xbps.d
echo "repository=https://repo-fastly.voidlinux.org/current/musl" > /mnt/etc/xbps.d/00-repository-main.conf

echo "[+] Installing base-system..."
xbps-install -Sy -r /mnt base-system

echo "[+] Copying files into /mnt..."
cp -r "$PROJECT_ROOT/chroot" /mnt/chroot
cp "$PROJECT_ROOT/00_env.sh" /mnt/00_env.sh

echo "[+] Entering chroot environment..."
xchroot /mnt /bin/bash /chroot/05_root.sh
