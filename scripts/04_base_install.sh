#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Setting up musl repository config..."
mkdir -p /mnt/var/db/xbps/keys
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
cp ./assets/xbps_arch.sh /etc/profile.d
source /etc/profile.d/xbps_arch.sh
mkdir -p /mnt/etc/xbps.d
mkdir -p /mnt/etc/profile.d
cp ./assets/xbps_arch.sh /mnt/etc/profile.d/
echo "repository=https://repo-default.voidlinux.org/current" > /mnt/etc/xbps.d/00-repository-main.conf

echo "[+] Installing base-system..."
XBPS_ARCH=x86_64-musl xbps-install -Sy -r /mnt base-system

echo "[+] Copying files into /mnt..."
cp -r "$PROJECT_ROOT/chroot" /mnt/chroot
cp "$PROJECT_ROOT/00_env.sh" /mnt/00_env.sh

echo "[+] Entering chroot environment..."
xchroot /mnt /bin/bash /chroot/05_root.sh
