#!/system/bin/sh
set -eu

MODDIR=${0%/*}
CLASHCTL_HOME="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
BIN="$CLASHCTL_HOME/system/bin/mihomo"
CONFIG_DIR="$CLASHCTL_HOME/data/config"
LOG_DIR="$CLASHCTL_HOME/data/logs"
PIDFILE="$CLASHCTL_HOME/data/clash.pid"
LOGFILE="$LOG_DIR/clash.log"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
SUBFILE="$CLASHCTL_HOME/data/subscriptions.txt"

mkdir -p "$CONFIG_DIR" "$LOG_DIR"
[ -f "$CONFIG_FILE" ] || cat > "$CONFIG_FILE" <<'YAML'
port: 7890
socks-port: 7891
mixed-port: 7892
allow-lan: true
bind-address: '*'
mode: rule
log-level: warning
external-controller: 127.0.0.1:9090
external-dns: true
YAML

clashctl_help() {
  cat <<'HELP'
Usage: clashctl [start|stop|status|ui|sub|config|logs|version]

  start       start mihomo in the background
  stop        stop mihomo
  status      show running state in JSON-ish format
  ui          show panel address
  sub add --use URL
              add a subscription URL
  sub list    list stored subscriptions
  sub delete ID
              remove a subscription
  config show
  config set KEY=VALUE
              update a simple config key
  logs [tail N]
              print recent logs
  version     show module and kernel version
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
    echo "running: $(cat "$PIDFILE")"
    return 0
  fi
  [ -x "$BIN" ] || {
    echo "mihomo binary not found: $BIN"
    return 1
  }
  nohup "$BIN" -d "$CONFIG_DIR" -f "$CONFIG_FILE" >>"$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  sleep 1
  echo "started: $(cat "$PIDFILE")"
}

run_stop() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID" || true
    fi
    rm -f "$PIDFILE"
  fi
  echo "stopped"
}

run_status() {
  if is_running; then
    echo "running: $(cat "$PIDFILE")"
  else
    echo "stopped"
  fi
}

run_ui() {
  echo "http://127.0.0.1:9090/"
}

run_sub() {
  action=${1:-list}
  shift || true
  case "$action" in
    add)
      [ "$1" = "--use" ] || { echo "Usage: clashctl sub add --use URL"; return 1; }
      URL=${2:-}
      [ -n "$URL" ] || { echo "Missing subscription URL"; return 1; }
      printf '%s\n' "$URL" >> "$SUBFILE"
      echo "subscription added: $URL"
      ;;
    list)
      if [ -f "$SUBFILE" ]; then
        nl -ba "$SUBFILE" 2>/dev/null || cat "$SUBFILE"
      else
        echo "No subscriptions configured."
      fi
      ;;
    delete)
      ID=${1:-}
      [ -n "$ID" ] || { echo "Usage: clashctl sub delete ID"; return 1; }
      if [ -f "$SUBFILE" ]; then
        tmp=$(mktemp)
        awk -v id="$ID" 'NR != id' "$SUBFILE" > "$tmp" && mv "$tmp" "$SUBFILE"
        echo "deleted subscription index: $ID"
      else
        echo "No subscriptions configured."
      fi
      ;;
    *)
      echo "Unsupported sub command: $action"
      return 1
      ;;
  esac
}

run_config() {
  action=${1:-show}
  case "$action" in
    show)
      if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
      else
        echo "No config file found"
      fi
      ;;
    set)
      kv=${2:-}
      [ -n "$kv" ] || { echo "Usage: clashctl config set KEY=VALUE"; return 1; }
      key=${kv%%=*}
      value=${kv#*=}
      if grep -Eq "^${key}:" "$CONFIG_FILE"; then
        sed -i "s#^${key}:.*#${key}: ${value}#" "$CONFIG_FILE"
      else
        printf '%s: %s\n' "$key" "$value" >> "$CONFIG_FILE"
      fi
      echo "updated config key: $key"
      ;;
    *)
      echo "Unsupported config action: $action"
      return 1
      ;;
  esac
}

run_logs() {
  tail -n "${1:-50}" "$LOGFILE" 2>/dev/null || echo "No logs yet"
}

run_version() {
  echo "clashctl-kernelsu v0.1.0"
}

case "${1:-help}" in
  start)
    run_start
    ;;
  on)
    run_start
    ;;
  stop)
    run_stop
    ;;
  off)
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
  config)
    shift
    run_config "$@"
    ;;
  logs)
    shift
    run_logs "$@"
    ;;
  version)
    run_version
    ;;
  help|-h|--help)
    clashctl_help
    ;;
  *)
    clashctl_help
    exit 1
    ;;
esac
