#!/system/bin/sh
set -eu

MODDIR="${0%/*}"
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
BIN="$CLASHCTL_HOME/system/bin/clashctl"

if [ ! -x "$BIN" ]; then
  echo "clashctl wrapper is missing: $BIN"
  exit 1
fi

"$BIN" start
