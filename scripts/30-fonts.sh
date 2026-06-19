#!/usr/bin/env bash
# Install the monochrome "Noto Emoji" font WITHOUT the AUR — just a download of
# the official variable font from Google Fonts. kstart draws B&W emoji with it
# ("Noto Emoji Medium", a named instance of this variable font); it's also a sane
# system-wide monochrome emoji fallback. The color NotoColorEmoji comes from the
# noto-fonts-emoji package (in packages/pacman.txt).
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

FONT_URL="https://github.com/google/fonts/raw/main/ofl/notoemoji/NotoEmoji%5Bwght%5D.ttf"
FONT_DEST="/usr/share/fonts/noto/NotoEmoji-VariableFont_wght.ttf"

if [[ -f "$FONT_DEST" ]]; then
  ok "Noto Emoji (monochrome) already installed"
  exit 0
fi

log "downloading Noto Emoji (monochrome) variable font from Google Fonts"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$FONT_URL" -o "$tmp"; then
  warn "could not download Noto Emoji font; skipping (monochrome emoji may be missing)"
  exit 0
fi

sudo install -Dm644 "$tmp" "$FONT_DEST"
sudo fc-cache -f >/dev/null 2>&1 || true
ok "Noto Emoji (monochrome) installed -> $FONT_DEST"
