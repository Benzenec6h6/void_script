#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Updating package database and xbps itself"
xbps-install -S
xbps-install -uy xbps

echo "[+] Installing kernel and related tools"
xbps-install -y linux linux-firmware dracut

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

# Bootloader installation
if [[ "$BOOTLOADER" == "grub" ]]; then
  echo "[+] Installing GRUB..."
  xbps-install -y grub-x86_64-efi efibootmgr dosfstools os-prober

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
