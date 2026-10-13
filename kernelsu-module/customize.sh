#!/system/bin/sh
set -eu

MODDIR=${0%/*}
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

mkdir -p "$MODDIR/data" "$MODDIR/data/config" "$MODDIR/data/profiles" "$MODDIR/data/logs"

if [ ! -f "$MODDIR/system/bin/mihomo" ]; then
  DOWNLOAD_URL="${MIHOMO_DOWNLOAD_URL:-https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-${ARCH_NAME}}"
  echo "Downloading mihomo (${ARCH_NAME}) from: $DOWNLOAD_URL"
  curl -fsSL "$DOWNLOAD_URL" -o "$MODDIR/system/bin/mihomo" || {
    echo "Failed to download mihomo from $DOWNLOAD_URL"
    echo "Set MIHOMO_DOWNLOAD_URL to a valid asset URL and reinstall the module."
    exit 1
  }
  chmod 0755 "$MODDIR/system/bin/mihomo"
fi

if [ ! -f "$MODDIR/data/config/config.yaml" ]; then
  cat > "$MODDIR/data/config/config.yaml" <<'YAML'
# Minimal configuration template for Android KernelSU runtime.
# Adjust as needed for your subscription or custom rules.
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
fi

cat > "$MODDIR/data/clashctl.env" <<EOF
CLASHCTL_HOME=/data/adb/modules/clashctl
CLASHCTL_KERNEL=mihomo
CLASHCTL_CONFIG_DIR=/data/adb/modules/clashctl/data/config
CLASHCTL_LOG_DIR=/data/adb/modules/clashctl/data/logs
CLASHCTL_DOWNLOAD_URL=$DOWNLOAD_URL
EOF

if [ -f "$MODDIR/system/bin/startup.sh" ]; then
  sh "$MODDIR/system/bin/startup.sh" || true
fi

echo "KernelSU module initialized for ${ARCH_NAME}."
