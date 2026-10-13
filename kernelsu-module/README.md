#!/system/bin/sh
set -eu

MODDIR=${0%/*}
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
BIN="$CLASHCTL_HOME/system/bin/clashctl"

if [ -x "$BIN" ]; then
  "$BIN" status >/dev/null 2>&1 || "$BIN" start || true
fi
