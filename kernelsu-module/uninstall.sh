#!/system/bin/sh
set -eu

MODDIR=${0%/*}
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
MODULE_ROOT="${MODDIR:-$CLASHCTL_HOME}"

if [ -f "$MODULE_ROOT/disable" ]; then
  echo "Module disabled; skipping start."
  exit 0
fi

if [ -x "$MODULE_ROOT/system/bin/clashctl" ]; then
  "$MODULE_ROOT/system/bin/clashctl" start
fi
