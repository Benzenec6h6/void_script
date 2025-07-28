#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/00_env.sh"

xbps-install -Sy -R "https://repo.voidlinux.org/current/musl" -r /mnt base-system

cp -r "$PROJECT_ROOT/chroot" /mnt/chroot
cp -r "$PROJECT_ROOT/00_env.sh" /mnt/00_env.sh

xchroot /mnt /bin/bash /chroot/05_root.sh
