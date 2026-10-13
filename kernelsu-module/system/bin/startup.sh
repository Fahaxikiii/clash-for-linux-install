#!/system/bin/sh
set -eu

MODDIR=${0%/*}
TARGET="$MODDIR/mihomo"
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64)
    ARCH_NAME=arm64
    ;;
  armv7l|armv8l)
    ARCH_NAME=armv7
    ;;
  x86_64|amd64)
    ARCH_NAME=amd64
    ;;
  *)
    echo "Unsupported device arch: $ARCH"
    exit 1
    ;;
esac

URL="${MIHOMO_DOWNLOAD_URL:-https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-${ARCH_NAME}}"
mkdir -p "$(dirname "$TARGET")"
curl -fsSL "$URL" -o "$TARGET" || {
  echo "Unable to download mihomo from $URL"
  exit 1
}
chmod 0755 "$TARGET"
echo "$TARGET"
