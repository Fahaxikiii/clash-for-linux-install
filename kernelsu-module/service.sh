#!/system/bin/sh
set -eu

MODDIR="${CLASHCTL_HOME:-/data/adb/modules/clashctl}"
PYTHON_BIN=""
for py in python3 python; do
  if command -v "$py" >/dev/null 2>&1; then
    PYTHON_BIN="$py"
    break
  fi
done

if [ -n "$PYTHON_BIN" ]; then
  exec "$PYTHON_BIN" "$MODDIR/system/bin/webroot.py"
fi

if command -v busybox >/dev/null 2>&1; then
  echo "Python not found; falling back to busybox httpd static mode."
  exec busybox httpd -f -p 9090 -h "$MODDIR/system/webroot"
fi

echo "This module needs python3 or busybox httpd to serve the web UI."
exit 1
