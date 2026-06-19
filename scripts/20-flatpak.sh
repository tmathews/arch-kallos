#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"
ROOT="$(repo_root "$0")"

command -v flatpak &>/dev/null || die "flatpak not installed (it should be in packages/pacman.txt)"

log "adding the Flathub remote (if missing)"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

mapfile -t apps < <(read_pkglist "$ROOT/packages/flatpak.txt")
if [[ ${#apps[@]} -gt 0 ]]; then
  log "installing Flatpak apps: ${apps[*]}"
  sudo flatpak install --noninteractive flathub "${apps[@]}"
  ok "Flatpak apps installed"
else
  warn "no Flatpak apps listed"
fi
