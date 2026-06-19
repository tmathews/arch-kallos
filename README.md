# arch-kallos

Post-install provisioning for my Arch Linux machines. The base OS is still
installed by hand from the USB ISO (or the `archinstall` menu); this repo takes a
freshly-booted system and brings it up to my standard setup with one command.

No AUR. GUI apps come from Flathub; everything else from the official repos.
Hardware drivers are auto-detected, so the same repo works across machines.

## Usage

After first boot, logged in as your normal user with a network connection:

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/arch-kallos/main/setup.sh -o setup.sh
less setup.sh        # inspect before running
bash setup.sh
```

`curl` is always present on Arch (it's a hard dependency of `pacman`), so nothing
needs installing first. `setup.sh` will install `git`, clone this repo to
`~/.local/share/arch-kallos`, and run the modules in `scripts/`.

Or clone it yourself and run locally (e.g. copied via USB):

```bash
git clone https://github.com/<user>/arch-kallos.git
cd arch-kallos && bash setup.sh
```

> **Before first use:** set `REPO_URL` at the top of `setup.sh` to your fork
> (or export `ARCH_KALLOS_REPO`).

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
| Services | `40-services.sh` | Enable system + user units that exist |
| User | `50-user.sh` | Add to `seat`/`plugdev` groups; set locale/timezone if unset |
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
```

## Editing the package set

- **Add/remove a regular package** → edit `packages/pacman.txt`.
- **Add a GUI app** → put its Flathub ID in `packages/flatpak.txt`
  (find it with `flatpak search <name>`).
- **Hardware drivers** are chosen automatically in `scripts/15-hardware.sh` —
  edit the detection there if you add new hardware classes.

## Out of scope

Dotfiles (niri, neovim, shell config, fcitx5 autostart) and network config files
(`*.network`, iwd) are not managed here — keep those in a separate dotfiles repo.
