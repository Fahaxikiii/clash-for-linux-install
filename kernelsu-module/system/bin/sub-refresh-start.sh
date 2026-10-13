#!/system/bin/sh
set -eu

# Start background subscription refresh (loop) if configured
MODDIR=${CLASHCTL_HOME:-/data/adb/modules/clashctl}
PIDFILE="$MODDIR/data/sub-refresh.pid"

if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null || true)
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    echo "sub-refresh already running: $PID"
    exit 0
  fi
fi

nohup "$MODDIR/system/bin/sub-refresh.sh" loop >/dev/null 2>&1 &
echo $! > "$PIDFILE"
echo "sub-refresh started: $(cat $PIDFILE)"
