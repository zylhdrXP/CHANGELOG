#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUT="$REPO_ROOT/CHANGELOG.md"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SINCE=()
if [ -f "$OUT" ]; then
  SINCE=(--since="24 hours ago")
fi

{
  echo "# Changelog"
  echo
  echo "Generated on: $(date -u +%Y-%m-%d)"
  echo

  for REPO in android_device_xiaomi_garnet proprietary_vendor_xiaomi_garnet android_device_xiaomi_garnet-miuicamera proprietary_vendor_xiaomi_garnet-miuicamera; do
    echo "## $REPO"
    echo
    git clone --quiet --no-checkout --single-branch --filter=blob:none \
      "https://github.com/Fleur-Project/$REPO" "$TMP/$REPO"
    LOG=$(git -C "$TMP/$REPO" log --oneline "${SINCE[@]}")
    if [ -n "$LOG" ]; then
      echo "$LOG" | sed 's/^/- /'
    else
      echo "- No commits in the last 24 hours."
    fi
    echo
  done

  echo "## Kernel"
  echo
  echo "- [android_kernel_xiaomi_sm7435](https://github.com/Fleur-Project/android_kernel_xiaomi_sm7435/commits/lineage-23.2/)"
  echo
  echo "## Kernel Modules"
  echo
  echo "- [android_kernel_xiaomi_sm7435-modules](https://github.com/Fleur-Project/android_kernel_xiaomi_sm7435-modules/commits/lineage-23.2/)"
  echo
} > "$OUT"