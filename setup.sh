#!/usr/bin/env bash
# arch-kallos — post-install provisioning for Arch Linux.
# Run after a fresh base install + first boot, as your normal user:
#   curl -fsSL https://raw.githubusercontent.com/<user>/arch-kallos/main/setup.sh -o setup.sh
#   bash setup.sh
set -euo pipefail

# Edit these (or override via env) to point at your fork.
REPO_URL="${ARCH_KALLOS_REPO:-https://github.com/tmathews/arch-kallos.git}"
CLONE_DIR="${ARCH_KALLOS_DIR:-$HOME/.local/share/arch-kallos}"

# When piped via `curl | bash` there is no checkout on disk: bootstrap by
# installing git, cloning the repo, and re-execing from the clone.
self="${BASH_SOURCE[0]:-}"
if [[ -n "$self" && -f "$(dirname "$(readlink -f "$self")")/lib/common.sh" ]]; then
  ROOT="$(cd "$(dirname "$(readlink -f "$self")")" && pwd)"
else
  echo "==> Bootstrapping arch-kallos (no local checkout detected)"
  if ! command -v git &>/dev/null; then
    echo "==> Installing git"
    sudo pacman -Sy --needed --noconfirm git
  fi
  if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "==> Updating existing clone at $CLONE_DIR"
    git -C "$CLONE_DIR" pull --ff-only || true
  else
    echo "==> Cloning $REPO_URL -> $CLONE_DIR"
    mkdir -p "$(dirname "$CLONE_DIR")"
    git clone "$REPO_URL" "$CLONE_DIR"
  fi
  exec bash "$CLONE_DIR/setup.sh" "$@"
fi

source "$ROOT/lib/common.sh"

log "arch-kallos provisioning starting"
log "repo root: $ROOT"

# Run the numbered modules in order.
for script in "$ROOT"/scripts/[0-9]*.sh; do
  log "── running $(basename "$script") ──"
  bash "$script"
done

ok "All done — review the notes above for any manual follow-ups."
