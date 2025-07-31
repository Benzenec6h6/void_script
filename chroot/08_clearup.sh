#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

dracut --force

echo "[+] Cleaning up chroot setup..."
rm -rf "$MOUNTPOINT/chroot"
rm -rf "$MOUNTPOINT/assets"
xbps-reconfigure -fa

echo "[+] Disabling swap..."
swapoff "${TARGET_DISK}2"

echo "[+] Unmounting filesystems..."
umount -R "$MOUNTPOINT"

echo "[+] Installation complete."
read -rp "Reboot now? (y/N): " reboot_choice
[[ $reboot_choice =~ ^[Yy]$ ]] && reboot
