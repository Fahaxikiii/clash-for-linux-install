#!/bin/bash
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
OUT="${1:-${SCRIPT_DIR}/clashctl-kernelsu-arm64.zip}"
cd "$SCRIPT_DIR"
rm -f "$OUT"
zip -r "$OUT" module.prop customize.sh service.sh uninstall.sh system >/dev/null

echo "Built module zip: $OUT"
