#!/system/bin/sh
set -eu

# Download subconverter binary to system/bin/subconverter
MODDIR=${0%/*}
TARGET="$MODDIR/system/bin/subconverter"

DOWNLOAD_URL="${SUBCONVERTER_DOWNLOAD_URL:-}"
if [ -z "$DOWNLOAD_URL" ]; then
  echo "SUBCONVERTER_DOWNLOAD_URL not set. Please set this env var to the subconverter release asset URL and rerun."
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$DOWNLOAD_URL" -o "$TARGET" || { echo "Download failed"; exit 1; }
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "$TARGET" "$DOWNLOAD_URL" || { echo "Download failed"; exit 1; }
else
  echo "curl or wget required to download subconverter"
  exit 1
fi

chmod 0755 "$TARGET"
echo "Downloaded subconverter to $TARGET"
