#!/usr/bin/env bash
# Apply the dotfiles arch-kallos manages: the niri config (verbatim copy) and
# small marker-delimited blocks injected into ~/.profile and ~/.bashrc. Personal
# and secret lines outside the managed blocks are never touched.
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"
ROOT="$(repo_root "$0")"
DOT="$ROOT/dotfiles"

# --- niri config: copy verbatim, backing up anything different ---
niri_src="$DOT/niri/config.kdl"
niri_dest="$HOME/.config/niri/config.kdl"
mkdir -p "$(dirname "$niri_dest")"
if [[ -f "$niri_dest" ]] && ! cmp -s "$niri_src" "$niri_dest"; then
  bak="$niri_dest.$(date +%Y%m%d%H%M%S).bak"
  cp -a "$niri_dest" "$bak"
  warn "existing niri config differed — backed up to $bak"
fi
install -Dm644 "$niri_src" "$niri_dest"
ok "niri config installed -> $niri_dest"

# --- ~/.profile: Wayland + fcitx5 environment (managed block) ---
inject_block "$HOME/.profile" "wayland-fcitx" "$(cat "$DOT/profile.fcitx.sh")"
ok "injected Wayland + fcitx5 env into ~/.profile"

# --- ~/.bashrc: start niri on TTY1 login (managed block) ---
inject_block "$HOME/.bashrc" "niri-autostart" "$(cat "$DOT/bashrc.niri.sh")"
ok "injected niri autostart into ~/.bashrc"

warn "log out of TTY1 and back in for the niri + env changes to take effect."
warn "if Japanese support is installed, pick the engine in fcitx5-configtool after login."