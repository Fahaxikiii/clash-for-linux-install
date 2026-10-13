#!/system/bin/sh
set -eu

# Simple subscription refresh script
# Usage: sub-refresh.sh [one-shot]
# If run without arguments, it runs once and exits. If run with 'loop' it will run periodically.

MODDIR=${CLASHCTL_HOME:-/data/adb/modules/clashctl}
SUBFILE="$MODDIR/data/subscriptions.txt"
OUTDIR="$MODDIR/data/subs"
CONFIG_DIR="$MODDIR/data/config"
BIN_SUBCONVERTER="$MODDIR/system/bin/subconverter"
BIN_CURL=""
for c in curl wget; do
  if command -v "$c" >/dev/null 2>&1; then BIN_CURL=$c; break; fi
done

mkdir -p "$OUTDIR" "$CONFIG_DIR"

fetch_one() {
  id="$1"
  url="$2"
  out_raw="$OUTDIR/$id.raw"
  out_yaml="$CONFIG_DIR/sub-$id.yaml"
  echo "[sub-refresh] fetching #$id: $url"
  if [ "$BIN_CURL" = "curl" ]; then
    curl -fsSL "$url" -o "$out_raw" || { echo "fetch failed: $url"; return 1; }
  else
    wget -q -O "$out_raw" "$url" || { echo "fetch failed: $url"; return 1; }
  fi
  # If subconverter available and user provided SUBCONVERTER_ARGS, try to convert
  if [ -x "$BIN_SUBCONVERTER" ] && [ -n "${SUBCONVERTER_ARGS:-}" ]; then
    echo "[sub-refresh] converting with subconverter"
    # The exact flags for subconverter may vary; SUBCONVERTER_ARGS should include placeholder {in} and {out}
    # Example: --in {in} --out {out} or --sub {in} --output {out}
    cmd=$(echo "$SUBCONVERTER_ARGS" | sed "s#{in}#$out_raw#g; s#{out}#$out_yaml#g")
    eval "$BIN_SUBCONVERTER $cmd" || echo "[sub-refresh] subconverter failed for $url"
  else
    # Try to guess if the raw file is already YAML; if so, copy to out_yaml
    if grep -Eq "^port:|^proxies:|^mixed-port:|^socks-port:" "$out_raw"; then
      cp -f "$out_raw" "$out_yaml"
    else
      # leave raw for manual inspection
      echo "[sub-refresh] saved raw subscription to $out_raw"
    fi
  fi
}

run_once() {
  if [ ! -f "$SUBFILE" ]; then
    echo "No subscriptions found ($SUBFILE)"
    return 0
  fi
  idx=0
  while IFS= read -r url || [ -n "$url" ]; do
    idx=$((idx+1))
    [ -n "$url" ] || continue
    fetch_one "$idx" "$url"
  done < "$SUBFILE"
  # optionally signal mihomo to reload configuration
  if [ -f "$MODDIR/data/clash.pid" ]; then
    pid=$(cat "$MODDIR/data/clash.pid" 2>/dev/null || true)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "[sub-refresh] signaling mihomo to reload (SIGHUP)"
      kill -HUP "$pid" || true
    fi
  fi
}

if [ "${1:-}" = loop ]; then
  INTERVAL=${REFRESH_INTERVAL:-3600}
  echo "Starting subscription refresh loop (interval ${INTERVAL}s)"
  while true; do
    run_once
    sleep "$INTERVAL"
  done
else
  run_once
fi
