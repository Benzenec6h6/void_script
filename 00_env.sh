#!/usr/bin/env bash
set -euo pipefail

# 共通変数
export MOUNTPOINT="/mnt"
export ARCH="amd64"
export HOSTNAME="void"
export TIMEZONE="Asia/Tokyo"
export TARGET_DISK=""
export BOOTLOADER=""
export NETMGR=""
export USERNAME=""
export PARTUUID=""
export is_vm=""
