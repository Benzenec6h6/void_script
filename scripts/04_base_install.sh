#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Downloading latest musl ROOTFS tarball..."

BASE_URL="https://repo-default.voidlinux.org/live/current"
ROOTFS_NAME=$(curl -s "$BASE_URL/" | grep -oE "void-${ARCH}-ROOTFS-[0-9]+\.tar\.xz" | sort -V | tail -n1)

echo "[+] Latest ROOTFS found: $ROOTFS_NAME"
curl -LO "$BASE_URL/$ROOTFS_NAME"

echo "[+] Extracting ROOTFS to $MOUNTPOINT"
mkdir -p "$MOUNTPOINT"
tar -xpf "$ROOTFS_NAME" -C "$MOUNTPOINT"

echo "[+] Setting up XBPS keys..."
mkdir -p "$MOUNTPOINT/var/db/xbps/keys"
cp -a /var/db/xbps/keys/* "$MOUNTPOINT/var/db/xbps/keys/"

echo "[+] Setting up xbps.d repository config..."
mkdir -p "$MOUNTPOINT/etc/xbps.d"
echo "repository=https://repo-default.voidlinux.org/current/musl" > "$MOUNTPOINT/etc/xbps.d/00-repository-main.conf"

echo "[+] Copying setup files into $MOUNTPOINT..."
cp -r "$SCRIPT_DIR/assets" "$MOUNTPOINT/assets"
cp -r "$SCRIPT_DIR/chroot" "$MOUNTPOINT/chroot"
cp "$SCRIPT_DIR/00_env.sh" "$MOUNTPOINT/00_env.sh"
mkdir -p "$MOUNTPOINT/lib/modules"
mkdir -p "$MOUNTPOINT/lib/firmware"
mkdir -p "$MOUNTPOINT/proc"
mkdir -p "$MOUNTPOINT/sys"
mkdir -p "$MOUNTPOINT/dev"
mount --bind /lib/modules "$MOUNTPOINT/lib/modules"
mount --bind /lib/firmware "$MOUNTPOINT/lib/firmware"
mount -t proc proc "$MOUNTPOINT/proc"
mount --rbind /sys "$MOUNTPOINT/sys"
mount --rbind /dev "$MOUNTPOINT/dev"

echo "[+] Generating fstab"
xgenfstab -U "$MOUNTPOINT" > "$MOUNTPOINT/etc/fstab"

echo "[+] Entering chroot environment..."
xchroot "$MOUNTPOINT" /bin/bash /chroot/05_root.sh