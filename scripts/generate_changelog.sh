#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUT="$REPO_ROOT/CHANGELOG.md"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

DAY="$(date -u +%Y-%m-%d)"
SECTION="$TMP/section.md"

if [ -f "$OUT" ] && grep -q "^## $DAY$" "$OUT"; then
  exit 0
fi

SINCE=()
if [ -f "$OUT" ]; then
  SINCE=(--since="24 hours ago")
fi

HAS_COMMITS=0

{
  for REPO in android_device_xiaomi_garnet proprietary_vendor_xiaomi_garnet android_device_xiaomi_garnet-miuicamera proprietary_vendor_xiaomi_garnet-miuicamera hardware_dolby; do
    echo "### $REPO"
    echo
    git clone --quiet --no-checkout --single-branch --filter=blob:none \
      "https://github.com/Fleur-Project/$REPO" "$TMP/$REPO"
    LOG=$(git -C "$TMP/$REPO" log --oneline "${SINCE[@]}")
    if [ -n "$LOG" ]; then
      echo "$LOG" | sed 's/^/- /'
      HAS_COMMITS=1
    else
      echo "- No new commits."
    fi
    echo
  done

  echo "### Kernel"
  echo
  echo "- [android_kernel_xiaomi_sm7435](https://github.com/Fleur-Project/android_kernel_xiaomi_sm7435/commits/lineage-23.2/)"
  echo
  echo "### Kernel Modules"
  echo
  echo "- [android_kernel_xiaomi_sm7435-modules](https://github.com/Fleur-Project/android_kernel_xiaomi_sm7435-modules/commits/lineage-23.2/)"
} > "$SECTION"

if [ "$HAS_COMMITS" -eq 0 ]; then
  echo "No new commits found for $DAY. Skipping changelog update."
  exit 0
fi

if [ -f "$OUT" ]; then
  {
    head -2 "$OUT"
    printf '## %s\n\n' "$DAY"
    cat "$SECTION"
    tail -n +3 "$OUT"
  } > "$OUT.new" && mv "$OUT.new" "$OUT"
else
  {
    echo "# Changelog"
    echo
    printf '## %s\n\n' "$DAY"
    cat "$SECTION"
  } > "$OUT"
fi