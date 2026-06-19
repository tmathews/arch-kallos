#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

pkgs=()

# --- CPU microcode ---
if grep -q 'AuthenticAMD' /proc/cpuinfo; then
  pkgs+=(amd-ucode);   log "CPU: AMD -> amd-ucode"
elif grep -q 'GenuineIntel' /proc/cpuinfo; then
  pkgs+=(intel-ucode); log "CPU: Intel -> intel-ucode"
else
  warn "unknown CPU vendor; skipping microcode"
fi

# --- GPU Vulkan driver ---
gpu="$(lspci 2>/dev/null | grep -iE 'vga|3d controller|display' || true)"
if [[ -z "$gpu" ]]; then
  warn "could not detect GPU (lspci unavailable?); skipping Vulkan driver"
else
  grep -qiE 'amd|ati|radeon' <<<"$gpu" && { pkgs+=(vulkan-radeon);        log "GPU: AMD -> vulkan-radeon"; }
  grep -qi  'intel'          <<<"$gpu" && { pkgs+=(vulkan-intel);         log "GPU: Intel -> vulkan-intel"; }
  grep -qi  'nvidia'         <<<"$gpu" && { pkgs+=(nvidia-open nvidia-utils); log "GPU: NVIDIA -> nvidia-open nvidia-utils"; }
fi

# --- Laptop bits (battery present) ---
if compgen -G '/sys/class/power_supply/BAT*' >/dev/null; then
  pkgs+=(brightnessctl sof-firmware)
  log "Laptop detected -> brightnessctl sof-firmware"
fi

# --- WiFi (a wireless network interface exists) ---
if compgen -G '/sys/class/net/*/wireless' >/dev/null; then
  pkgs+=(iwd iw)
  log "WiFi device detected -> iwd iw"
fi

# --- Bluetooth (adapter present) ---
if compgen -G '/sys/class/bluetooth/*' >/dev/null \
   || { command -v rfkill &>/dev/null && rfkill list 2>/dev/null | grep -qi bluetooth; }; then
  pkgs+=(bluez bluez-utils)
  log "Bluetooth detected -> bluez bluez-utils"
fi

if [[ ${#pkgs[@]} -gt 0 ]]; then
  log "installing hardware packages: ${pkgs[*]}"
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  ok "hardware packages installed"
else
  warn "no hardware-specific packages were selected"
fi
