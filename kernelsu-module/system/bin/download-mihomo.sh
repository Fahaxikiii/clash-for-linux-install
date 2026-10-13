#!/system/bin/sh
set -eu

MODDIR="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
BIN="$MODDIR/system/bin/mihomo"
CONFIG_DIR="$MODDIR/data/config"
LOG_DIR="$MODDIR/data/logs"
PIDFILE="$MODDIR/data/clash.pid"
LOGFILE="$LOG_DIR/clash.log"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

mkdir -p "$CONFIG_DIR" "$LOG_DIR"
[ -f "$CONFIG_FILE" ] || {
  echo "Missing config at $CONFIG_FILE"
  exit 1
}

clashctl_help() {
  cat <<'HELP'
Usage: clashctl [on|off|start|stop|status|ui|sub add --use <URL>]

  on          start the service and set the running state
  off         stop the service
  start       launch mihomo in the background
  stop        stop mihomo
  status      show running status
  ui          print the web UI URL
  sub add --use URL
              save a subscription URL for manual use
HELP
}

is_running() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

run_start() {
  if is_running; then
    echo "mihomo is already running (PID $(cat "$PIDFILE"))"
    return 0
  fi
  nohup "$BIN" -d "$CONFIG_DIR" -f "$CONFIG_FILE" >>"$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  sleep 1
  echo "mihomo started: $(cat "$PIDFILE")"
}

run_stop() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID" || true
    fi
    rm -f "$PIDFILE"
  fi
  echo "mihomo stopped"
}

run_status() {
  if is_running; then
    echo "running: $(cat "$PIDFILE")"
  else
    echo "stopped"
  fi
}

run_ui() {
  echo "http://127.0.0.1:9090/ui/"
}

run_sub() {
  if [ "$#" -lt 3 ]; then
    echo "Usage: clashctl sub add --use <URL>"
    return 1
  fi
  if [ "$1" != "add" ] || [ "$2" != "--use" ]; then
    echo "Unsupported sub-command"
    return 1
  fi
  URL="$3"
  printf '%s\n' "$URL" > "$MODDIR/data/subscription-url.txt"
  echo "Saved subscription URL to $MODDIR/data/subscription-url.txt"
  echo "The module is a minimal Android wrapper; apply the subscription manually or update config.yaml as needed."
}

case "${1:-help}" in
  on|start)
    run_start
    ;;
  off|stop)
    run_stop
    ;;
  status)
    run_status
    ;;
  ui)
    run_ui
    ;;
  sub)
    shift
    run_sub "$@"
    ;;
  help|-h|--help)
    clashctl_help
    ;;
  *)
    clashctl_help
    exit 1
    ;;
esac
