# arch-kallos

Post-install provisioning for my Arch Linux machines. The base OS is still
installed by hand from the USB ISO (or the `archinstall` menu); this repo takes a
freshly-booted system and brings it up to my standard setup with one command.

No AUR. GUI apps come from Flathub; everything else from the official repos.
Hardware drivers are auto-detected, so the same repo works across machines.

## Usage

After first boot, logged in as your normal user with a network connection:

```bash
curl -fsSL https://raw.githubusercontent.com/tmathews/arch-kallos/main/setup.sh -o setup.sh
less setup.sh        # inspect before running
bash setup.sh
```

`curl` is always present on Arch (it's a hard dependency of `pacman`), so nothing
needs installing first. `setup.sh` will install `git`, clone this repo to
`~/.local/share/arch-kallos`, and run the modules in `scripts/`.

Or clone it yourself and run locally (e.g. copied via USB):

```bash
git clone https://github.com/tmathews/arch-kallos.git
cd arch-kallos && bash setup.sh
```

> Using a fork? Override the clone source with `ARCH_KALLOS_REPO`
> (or edit `REPO_URL` at the top of `setup.sh`).

The run asks two yes/no questions: install common dev tools, and install Japanese
support. Everything else is non-interactive and safe to re-run (idempotent).

## What it does

| Step | Module | Action |
|------|--------|--------|
| Preflight | `00-preflight.sh` | Assert Arch, non-root, working sudo, network |
| Core | `10-pacman.sh` | Disable `multilib`, `pacman -Syu`, install `packages/pacman.txt` |
| Hardware | `15-hardware.sh` | Detect CPU/GPU/laptop/wifi/bluetooth → install the right drivers |
| Optional | `17-optional.sh` | Prompt for dev tools / Japanese support |
| Flatpak | `20-flatpak.sh` | Add Flathub, install `packages/flatpak.txt` |
| Fonts | `30-fonts.sh` | Download the monochrome Noto Emoji font (no AUR) |
| Services | `40-services.sh` | Enable system + user units that exist |
| User | `50-user.sh` | Add to `seat`/`plugdev` groups; set locale/timezone if unset |
| Dotfiles | `60-dotfiles.sh` | Copy niri config; inject Wayland+fcitx5 env / niri launch |
| Kallos | `80-kallos.sh` | If you can reach the private Kallos repo, build + install it |
| Notes | `90-postnotes.sh` | Print manual follow-ups |

## Layout

```
setup.sh              orchestrator + curl|bash bootstrap
lib/common.sh         shared helpers (logging, prompts, list parsing)
packages/
  pacman.txt          always-installed core
  pacman-dev.txt      gated: dev tools
  pacman-jp.txt       gated: Japanese support
  flatpak.txt         Flathub app IDs
scripts/NN-*.sh       numbered, idempotent steps run in order
dotfiles/
  niri/config.kdl     copied verbatim to ~/.config/niri/
  profile.fcitx.sh    injected into ~/.profile (Wayland + fcitx5 env)
  bashrc.niri.sh      injected into ~/.bashrc (start niri on TTY1)
```

## Dotfiles (partial)

`scripts/60-dotfiles.sh` manages only the pieces tied to this system setup:

- **niri config** — copied verbatim from `dotfiles/niri/config.kdl` (existing one
  is backed up if it differs).
- **`~/.profile` and `~/.bashrc`** — a marker-delimited block is injected/updated:
  ```sh
  # >>> arch-kallos:<id> >>>
  ...managed lines...
  # <<< arch-kallos:<id> <<<
  ```
  Re-runs replace the block in place; **anything outside the markers — your
  personal config and secrets — is never touched**. This is deliberate: keep
  credentials (e.g. SVN passwords) in your own un-managed lines, never in this repo.

The input-method block sets fcitx5 vars (`GTK/QT/SDL_IM_MODULE=fcitx`,
`XMODIFIERS=@im=fcitx`) and the niri config autostarts `fcitx5`. Your editor,
PATH, neovim/shell theming, etc. remain personal and are out of scope.

## Editing the package set

- **Add/remove a regular package** → edit `packages/pacman.txt`.
- **Add a GUI app** → put its Flathub ID in `packages/flatpak.txt`
  (find it with `flatpak search <name>`).
- **Hardware drivers** are chosen automatically in `scripts/15-hardware.sh` —
  edit the detection there if you add new hardware classes.

## Custom software: the Kallos desktop experience

`kstart` (overlay launcher) + `kdaemon` are built from a **private** repo via a
PKGBUILD (`kallos/PKGBUILD`) so the result is a real, pacman-tracked package
rather than loose files from `cmake --install`. The win: build-only dependencies
(the toolchain, headers, and the vkvg shader compiler) are listed as
`makedepends`, installed for the build, and **pruned afterward** — only the
runtime libraries in `depends` stay.

`scripts/80-kallos.sh` runs last and:

1. **Gates on access** — `git ls-remote` the private repo; if your SSH key can't
   reach it, the step skips silently (so this repo is safe to share).
2. Builds with `makepkg` in a tempdir (vkvg is fetched + compiled from source on
   first build — needs network during the build).
3. `pacman -U` installs it, then prunes the build-only deps that are now orphaned
   (dev tools you opted into earlier, and `git`, are kept).

Remove it later with `pacman -Rns kallos-git`. To point at a different repo,
export `KALLOS_GIT`. `kdaemon` is spawned on demand by `kstart`, so there's no
service to enable — bind `kstart` in your niri config (dotfiles).

## Out of scope

The rest of your dotfiles (neovim config, shell aliases/prompt, fcitx5 engine
selection) and network config files (`*.network`, iwd) are not managed here —
keep those personal or in a separate dotfiles repo.
