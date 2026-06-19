#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

# Arch only.
[[ -f /etc/arch-release ]] || die "this script targets Arch Linux only"

# Must run as a normal user; we escalate with sudo where needed.
[[ $EUID -ne 0 ]] || die "run as your normal user, not root (the script uses sudo itself)"

command -v sudo &>/dev/null || die "sudo is required but not installed"
log "validating sudo (you may be prompted for your password)"
sudo -v || die "sudo authentication failed"

# Network reachability (curl is guaranteed present — it's a pacman dependency).
if ! curl -fsS --max-time 5 https://archlinux.org >/dev/null 2>&1; then
  warn "could not reach archlinux.org — are you online? (use iwctl for wifi)"
  ask_yes_no "Continue anyway?" || die "aborted: no network"
fi

ok "preflight checks passed"
