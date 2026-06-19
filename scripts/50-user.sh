#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"

user="$(id -un)"

# Groups: seat (seatd / niri session access), plugdev (YubiKey udev rules).
for grp in seat plugdev; do
  if getent group "$grp" &>/dev/null; then
    if id -nG "$user" | tr ' ' '\n' | grep -qx "$grp"; then
      ok "already in group: $grp"
    else
      sudo usermod -aG "$grp" "$user" && ok "added $user to group $grp"
    fi
  else
    warn "group does not exist, skipping: $grp"
  fi
done

# Locale — only if not already configured (the base install usually does this).
if [[ ! -s /etc/locale.conf ]]; then
  log "setting locale to en_US.UTF-8"
  sudo sed -i 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  sudo locale-gen
  echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf >/dev/null
  ok "locale configured"
else
  ok "locale already configured"
fi

# Timezone — only if not already set.
if [[ ! -L /etc/localtime ]]; then
  log "setting timezone to America/Vancouver"
  sudo ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
  sudo hwclock --systohc || true
  ok "timezone configured"
else
  ok "timezone already configured"
fi

ok "user configuration done"
