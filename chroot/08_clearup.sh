#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo 'add_drivers+=" vfat fat "' > /etc/dracut.conf.d/vfat.conf
dracut --force /boot/initramfs-$(uname -r).img $(uname -r)

echo "[+] Cleaning up chroot setup..."
rm -rf "$MOUNTPOINT/chroot"
rm -rf "$MOUNTPOINT/assets"
xbps-reconfigure -fa

echo "[+] Disabling swap..."
swapoff "${TARGET_DISK}2"

echo "[+] Unmounting filesystems..."
umount -l /mnt/lib/modules
umount /mnt/boot/efi
umount /mnt  # これで最後に本体を解除

echo "[+] Installation complete."
read -rp "Reboot now? (y/N): " reboot_choice
[[ $reboot_choice =~ ^[Yy]$ ]] && reboot
