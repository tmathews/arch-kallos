#!/usr/bin/env bash
# Shared helpers for arch-kallos. Source this file; do not execute it.

# Colorize only when writing to a terminal.
if [[ -t 1 ]]; then
  _c_red=$'\033[31m'; _c_grn=$'\033[32m'; _c_ylw=$'\033[33m'; _c_blu=$'\033[34m'; _c_rst=$'\033[0m'
else
  _c_red=""; _c_grn=""; _c_ylw=""; _c_blu=""; _c_rst=""
fi

log()  { printf '%s==>%s %s\n' "$_c_blu" "$_c_rst" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$_c_grn" "$_c_rst" "$*"; }
warn() { printf '%swarn%s %s\n' "$_c_ylw" "$_c_rst" "$*" >&2; }
die()  { printf '%serror%s %s\n' "$_c_red" "$_c_rst" "$*" >&2; exit 1; }

# Resolve the repo root from any script living in scripts/.
repo_root() { cd "$(dirname "$(dirname "$(readlink -f "$1")")")" && pwd; }

# Yes/no prompt that works even when the script was piped from `curl | bash`,
# by reading from the controlling terminal. Defaults to No.
ask_yes_no() {
  local prompt="$1" reply
  if [[ ! -r /dev/tty ]]; then
    warn "no terminal available; defaulting to NO for: $prompt"
    return 1
  fi
  printf '%s [y/N] ' "$prompt" >/dev/tty
  read -r reply </dev/tty || reply=""
  [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# Read a package-list file, stripping comments and blank lines.
read_pkglist() {
  local f="$1"
  [[ -f "$f" ]] || die "package list not found: $f"
  grep -vE '^[[:space:]]*(#|$)' "$f"
}

# Install every package named in a list file (only the missing ones).
pacman_install_list() {
  local f="$1"; local pkgs=()
  mapfile -t pkgs < <(read_pkglist "$f")
  [[ ${#pkgs[@]} -gt 0 ]] || { warn "empty package list: $f"; return 0; }
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

# Enable systemd units that actually exist. Pass --user for the user manager.
enable_unit_if_exists() {
  local userflag=""
  if [[ "${1:-}" == "--user" ]]; then userflag="--user"; shift; fi
  local unit
  for unit in "$@"; do
    if systemctl $userflag list-unit-files "$unit" 2>/dev/null | grep -q "^${unit}"; then
      if [[ -n "$userflag" ]]; then
        systemctl --user enable "$unit" && ok "enabled (user) $unit" || warn "could not enable user unit $unit"
      else
        sudo systemctl enable "$unit" && ok "enabled $unit" || warn "could not enable $unit"
      fi
    else
      warn "unit not present, skipping: $unit"
    fi
  done
}
