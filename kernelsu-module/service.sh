#!/system/bin/sh
set -eu

# Start module services: mihomo, webroot, sub-refresh
MODDIR=${0%/*}
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"

# start mihomo via clashctl
if [ -x "$CLASHCTL_HOME/system/bin/clashctl" ]; then
  "$CLASHCTL_HOME/system/bin/clashctl" start || true
fi

# start web UI
if [ -x "$CLASHCTL_HOME/system/bin/webroot_launcher.sh" ]; then
  "$CLASHCTL_HOME/system/bin/webroot_launcher.sh" >/dev/null 2>&1 &
  echo $! > "$CLASHCTL_HOME/data/webroot.pid"
fi

# start subscription refresh loop if SUB_REFRESH_LOOP is enabled
if [ "${SUB_REFRESH_LOOP:-1}" != "0" ]; then
  if [ -x "$CLASHCTL_HOME/system/bin/sub-refresh-start.sh" ]; then
    "$CLASHCTL_HOME/system/bin/sub-refresh-start.sh" >/dev/null 2>&1 || true
  fi
fi

echo "module services started"
