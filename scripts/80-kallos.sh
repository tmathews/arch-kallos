#!/usr/bin/env bash
# Install the private Kallos desktop experience (kstart + kdaemon) IF this machine
# has access to the private repo. Builds via makepkg so the package is pacman-
# tracked, then removes the build-only dependencies makepkg pulled in.
set -euo pipefail
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/common.sh"
ROOT="$(repo_root "$0")"

KALLOS_GIT="${KALLOS_GIT:-git@github.com:tmathews/kstart.git}"
PKGDIR="$ROOT/kallos"

# --- access gate: skip silently on machines without your SSH key ---
log "checking access to the private Kallos repo ($KALLOS_GIT)"
if ! GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=8' \
       git ls-remote "$KALLOS_GIT" &>/dev/null; then
  warn "no access to the private Kallos repo — skipping (normal without your SSH key)"
  exit 0
fi
ok "access confirmed"

ask_yes_no "Build and install the Kallos desktop experience (kstart + kdaemon)?" \
  || { log "skipping Kallos install"; exit 0; }

command -v makepkg &>/dev/null || die "makepkg not found (base-devel should provide it)"
[[ -f "$PKGDIR/PKGBUILD" ]] || die "PKGBUILD not found at $PKGDIR"

# Read the declared makedepends straight from the PKGBUILD (no duplicated list).
mapfile -t MAKEDEPS < <(
  # shellcheck source=/dev/null
  source "$PKGDIR/PKGBUILD" >/dev/null 2>&1; printf '%s\n' "${makedepends[@]}"
)

# Build in a throwaway dir so nothing lands in the repo.
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
cp "$PKGDIR/PKGBUILD" "$workdir/"

log "building the Kallos package (makepkg installs build deps, then we prune them)"
( cd "$workdir" && PKGDEST="$workdir" SRCDEST="$workdir" \
    makepkg -sf --noconfirm --cleanbuild )

pkgfile="$(ls -t "$workdir"/*.pkg.tar.* 2>/dev/null | head -1 || true)"
[[ -n "$pkgfile" ]] || die "makepkg did not produce a package file"

log "installing $(basename "$pkgfile")"
sudo pacman -U --noconfirm "$pkgfile"
ok "Kallos installed"

# Prune build-only deps that makepkg pulled and nothing now needs. We only touch
# packages that are (a) installed as a dependency, not explicit, and (b) orphaned
# — so dev tools you chose earlier (clang/cmake) and core tools (git) are kept.
to_remove=()
for p in "${MAKEDEPS[@]}"; do
  pacman -Qq "$p" &>/dev/null || continue
  reason="$(pacman -Qi "$p" | awk -F': +' '/^Install Reason/{print $2; exit}')"
  reqby="$(pacman -Qi "$p"  | awk -F': +' '/^Required By/{print $2; exit}')"
  [[ "$reason" == *dependency* && "$reqby" == "None" ]] && to_remove+=("$p")
done
if ((${#to_remove[@]})); then
  log "removing build-only dependencies: ${to_remove[*]}"
  sudo pacman -Rs --noconfirm "${to_remove[@]}" || warn "could not remove some build deps"
else
  ok "no build-only deps to prune (already wanted, or never installed)"
fi

warn "kdaemon is spawned on demand by kstart — bind 'kstart' in your niri config (dotfiles)."
ok "Kallos step complete"
