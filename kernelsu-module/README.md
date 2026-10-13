#!/system/bin/sh
set -eu

MODDIR=${0%/*}
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
WA_DIR="$CLASHCTL_HOME/system/webroot"
mkdir -p "$CLASHCTL_HOME/data" "$CLASHCTL_HOME/data/config" "$CLASHCTL_HOME/data/logs" "$WA_DIR"

if [ -f "$CLASHCTL_HOME/system/bin/clashctl" ]; then
  "$CLASHCTL_HOME/system/bin/clashctl" start || true
fi

# Start the local KernelSU web interface on port 9090.
if [ -f "$CLASHCTL_HOME/system/bin/webroot.sh" ]; then
  if [ -f "$CLASHCTL_HOME/data/webroot.pid" ]; then
    PID=$(cat "$CLASHCTL_HOME/data/webroot.pid" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      echo "webroot already running (${PID})"
      exit 0
    fi
  fi
  "$CLASHCTL_HOME/system/bin/webroot.sh" >/dev/null 2>&1 &
  echo $! > "$CLASHCTL_HOME/data/webroot.pid"
  echo "webroot started on http://127.0.0.1:9090/"
fi
