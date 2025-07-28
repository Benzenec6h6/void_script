#!/usr/bin/env bash
set -euo pipefail

for script in ./scripts/{01..04}_*.sh; do
  echo "==> Running $script"
  bash "$script"
done