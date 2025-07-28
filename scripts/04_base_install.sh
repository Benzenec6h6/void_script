#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/env/env.sh"
source "$ENV_FILE"

xbps-install -Sy -R "https://repo.voidlinux.org/current/musl" -r /mnt base-system

cp -r "$PROJECT_ROOT/chroot" /mnt/chroot
cp -r "$PROJECT_ROOT/00_env.sh" /mnt/00_env.sh

xchroot /mnt /bin/bash /chroot/05_root.sh
