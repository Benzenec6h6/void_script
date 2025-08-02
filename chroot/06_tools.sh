#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Updating package database and xbps itself"
xbps-install -S
xbps-install -uy xbps

echo "[+] Installing kernel and related tools"
xbps-install -y linux linux-firmware dracut

# Bootloader installation
xbps-install -y efibootmgr
mkdir -p /boot/efi
mountpoint -q /boot/efi || mount "${TARGET_DISK}1" /boot/efi
if [[ "$BOOTLOADER" == "grub" ]]; then
  echo "[+] Installing GRUB..."
  xbps-install -y grub-x86_64-efi os-prober

  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=VoidLinux
  grub-mkconfig -o /boot/grub/grub.cfg

elif [[ "$BOOTLOADER" == "EFISTUB" ]]; then
  echo "[+] Setting up EFISTUB boot entry..."

  BOOT_EFI_DIR=/boot/efi/EFI/VoidLinux
  mkdir -p "$BOOT_EFI_DIR"

  KERNEL_SRC=$(ls /boot/vmlinuz-* | head -n1)
  INITRD_SRC=$(ls /boot/initramfs-* | head -n1)

  KERNEL_FILE=$(basename "$KERNEL_SRC")
  INITRD_FILE=$(basename "$INITRD_SRC")

  cp "$KERNEL_SRC" "$BOOT_EFI_DIR/$KERNEL_FILE"
  cp "$INITRD_SRC" "$BOOT_EFI_DIR/$INITRD_FILE"

  PARTUUID=$(blkid -s PARTUUID -o value "${TARGET_DISK}3")

  efibootmgr --create --disk "$TARGET_DISK" --part 1 \
    --label "VoidLinux" \
    --loader "\\EFI\\VoidLinux\\$KERNEL_FILE" \
    --unicode "root=PARTUUID=$PARTUUID rw initrd=\\EFI\\VoidLinux\\$INITRD_FILE" \
    --verbose
else
  echo "[!] Unknown bootloader: $BOOTLOADER"
  exit 1
fi
