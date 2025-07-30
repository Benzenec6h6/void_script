#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

# wait for /lib/modules to be populated
KERNEL_VERSION=$(xbps-query -R -f linux | grep ^/lib/modules | sed 's|/lib/modules/||' | cut -d/ -f1)
MODULE_DIR="/lib/modules/$KERNEL_VERSION"

if [[ ! -d "$MODULE_DIR" ]]; then
  echo "[!] Kernel modules directory not found: $MODULE_DIR"
  echo "[*] Waiting for it to be created..."
  sleep 2
fi

if [[ -d "$MODULE_DIR" ]]; then
  echo "[+] Running dracut..."
  dracut --force
else
  echo "[!] Kernel modules still not found, running dracut with --no-kernel"
  dracut --no-kernel --force
fi

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
