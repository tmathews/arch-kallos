#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

cat <<'EOF'

================= manual follow-ups =================
  * Re-login or reboot so new group membership (seat, plugdev) applies.
  * WiFi:        iwctl station <device> connect <SSID>
  * Sensors:     sudo sensors-detect
  * Firmware:    fwupdmgr refresh && fwupdmgr update
  * pkgfile db:  sudo pkgfile --update
  * Dotfiles:    niri config + Wayland/fcitx5 env are applied by 60-dotfiles.sh.
                 neovim / shell aliases are still personal (not managed here).
                 Japanese: pick the engine in fcitx5-configtool after first login.
  * qrcp (optional): grab a prebuilt binary from
                 https://github.com/claudiodangelis/qrcp/releases
====================================================
EOF
