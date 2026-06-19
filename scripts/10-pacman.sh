#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"
ROOT="$(repo_root "$0")"

# Disable the [multilib] repo if enabled — Steam is now a Flatpak and nothing
# else here needs 32-bit packages.
if grep -qE '^[[:space:]]*\[multilib\]' /etc/pacman.conf; then
  log "disabling [multilib] in /etc/pacman.conf (backup at pacman.conf.bak)"
  sudo cp -n /etc/pacman.conf /etc/pacman.conf.bak
  sudo sed -i -E '/^[[:space:]]*\[multilib\]/,/^[[:space:]]*Include[[:space:]]*=/ s/^/#/' /etc/pacman.conf
  ok "multilib disabled"
else
  ok "multilib already disabled"
fi

log "synchronizing databases and upgrading the system"
sudo pacman -Syu --noconfirm

log "installing core packages"
pacman_install_list "$ROOT/packages/pacman.txt"
ok "core packages installed"
