#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Updating package database and xbps itself"
xbps-install -S
xbps-install -uy xbps

echo "[+] Installing kernel and related tools"
xbps-install -y linux linux-firmware dracut
mount --bind /lib/modules /mnt/lib/modules
mount --bind /lib/firmware /mnt/lib/firmware

# Bootloader installation
xbps-install -y efibootmgr dosfstools
if [[ "$BOOTLOADER" == "grub" ]]; then
  echo "[+] Installing GRUB..."
  xbps-install -y grub-x86_64-efi os-prober

  mkdir -p /boot/efi
  mountpoint -q /boot/efi || mount "${TARGET_DISK}1" /boot/efi

  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=VoidLinux
  grub-mkconfig -o /boot/grub/grub.cfg

elif [[ "$BOOTLOADER" == "EFISTUB" ]]; then
  echo "[+] Setting up EFISTUB boot entry..."

  KERNEL=$(ls /boot/vmlinuz-* | head -n1)
  INITRD=$(ls /boot/initramfs-* | head -n1)
  PARTUUID=$(blkid -s PARTUUID -o value "${TARGET_DISK}3")

  efibootmgr --create --disk "$TARGET_DISK" --part 1 \
    --label "VoidLinux" \
    --loader "\\vmlinuz-$(basename "$KERNEL")" \
    --unicode "root=PARTUUID=$PARTUUID rw initrd=\\initramfs-$(basename "$INITRD")" \
    --verbose
else
  echo "[!] Unknown bootloader: $BOOTLOADER"
  exit 1
fi
