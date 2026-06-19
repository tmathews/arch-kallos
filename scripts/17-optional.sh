#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"
ROOT="$(repo_root "$0")"

if ask_yes_no "Install common dev tools (clang, gdb, cmake, meson)?"; then
  pacman_install_list "$ROOT/packages/pacman-dev.txt"
  ok "dev tools installed"
else
  log "skipping dev tools"
fi

if ask_yes_no "Install Japanese support (fcitx5 + mozc + CJK fonts)?"; then
  pacman_install_list "$ROOT/packages/pacman-jp.txt"
  ok "Japanese support installed"
  warn "fcitx5 still needs autostart + IM env vars (GTK_IM_MODULE/QT_IM_MODULE/XMODIFIERS=@im=fcitx); set these in your dotfiles"
else
  log "skipping Japanese support"
fi
