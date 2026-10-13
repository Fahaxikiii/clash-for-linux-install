# KernelSU clashctl module - README additions

This module implements the full-featured KernelSU variant of clashctl with a web-based control UI.

Key features implemented in this final-version branch:
- Web UI served on 127.0.0.1:9090 (requires python3 or busybox httpd)
- Start/Stop/Status/Logs via web UI
- Subscription add/list/delete via web UI
- Subscription refresh loop (background) with optional subconverter conversion
- Download helper for subconverter (set SUBCONVERTER_DOWNLOAD_URL env)

How to install (device-side):
1. Build module zip on host (run kernelsu-module/build.sh in repo). This generates a zip under the module directory.
2. Transfer and install the module via KernelSU UI or place it into /data/adb/modules/clashctl
3. Ensure device has curl or wget available. For web UI, ensure python3 is installed or busybox httpd.
4. Enable module and reboot or run the module service start script:
   sh /data/adb/modules/clashctl/service.sh

Config and optional setup:
- To enable automatic subscription refresh loop, set REFRESH_INTERVAL and ensure SUB_REFRESH_LOOP=1 in module environment.
- To enable automatic conversion using subconverter, set SUBCONVERTER_DOWNLOAD_URL to a valid asset URL and run:
  sh /data/adb/modules/clashctl/system/bin/download-subconverter.sh
  Then set SUBCONVERTER_ARGS to the invocation flags including placeholders {in} and {out} (e.g. "--sub {in} --output {out}").

Security note:
- This version deliberately does not implement web UI authentication (you previously opted out). The web UI binds to 127.0.0.1 only. Consider using a local VPN/secure tunnel if remote access is required.
