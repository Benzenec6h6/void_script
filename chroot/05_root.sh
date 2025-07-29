#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

echo "[+] Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

echo "[+] Setting timezone to $TIMEZONE"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc --utc

echo "[+] Setting locale"
echo "en_US.UTF-8 UTF-8" > /etc/default/libc-locales
xbps-reconfigure -f glibc-locales || true  # if using glibc
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
export LANG=en_US.UTF-8

echo "[+] Setting root password"
passwd

echo "[+] Creating user: $USERNAME"
useradd -mG wheel,audio,video,input -s /bin/bash "$USERNAME"
passwd "$USERNAME"

echo "[+] Installing sudo"
xbps-install -y sudo
sed -i 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|' /etc/sudoers

for script in /chroot/{06..08}_*.sh; do
  bash "$script"
done