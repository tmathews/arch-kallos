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
  * Dotfiles:    clone your niri / neovim / shell configs (not managed here).
                 If you installed Japanese support, set up fcitx5 autostart and
                 GTK_IM_MODULE / QT_IM_MODULE / XMODIFIERS in your dotfiles.
  * qrcp (optional): grab a prebuilt binary from
                 https://github.com/claudiodangelis/qrcp/releases
====================================================
EOF
