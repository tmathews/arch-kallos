#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

# System services. bluetooth/iwd units only exist if 15-hardware.sh installed
# them, so enable_unit_if_exists silently skips them otherwise.
log "enabling system services"
enable_unit_if_exists \
  seatd.service \
  systemd-networkd.service \
  systemd-resolved.service \
  systemd-timesyncd.service \
  udisks2.service \
  fstrim.timer \
  pcscd.socket \
  bluetooth.service \
  iwd.service

# User services (PipeWire sockets are preset-enabled; we ensure the rest).
log "enabling user services"
enable_unit_if_exists --user wireplumber.service xdg-user-dirs.service

ok "services configured"
