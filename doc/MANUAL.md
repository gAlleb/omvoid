# OMVOID Manual

OMVOID turns a bare [Void Linux](https://voidlinux.org/) installation into a
configured desktop built around [MangoWC](https://github.com/DreamMaoMao/mango),
a dwl-based Wayland compositor. It is not a package: it is a git checkout that
stays on the machine at `~/.local/share/omvoid` and keeps owning its configs.

This manual is for using and living with an installed system. For working on
OMVOID itself, see [AGENTS.md](AGENTS.md) and the guides under
`default/agents/skills/omvoid/`.

## Contents

- [Installing](#installing)
- [Installing from an image](#installing-from-an-image)
- [What is in it](#what-is-in-it)
- [What omvoid puts on the EFI partition](#what-omvoid-puts-on-the-efi-partition)
- [How long the install takes, and why](#how-long-the-install-takes-and-why)
- [Everyday commands](#everyday-commands)
- [Themes and wallpapers](#themes-and-wallpapers)
- [Keeping several machines in sync](#keeping-several-machines-in-sync)
- [Migrations](#migrations)
- [AI coding agents](#ai-coding-agents)
- [Adding your own things](#adding-your-own-things)
- [Where things live](#where-things-live)
- [Troubleshooting](#troubleshooting)

## Installing

On a fresh Void installation, from your user shell:

```bash
curl -fsSL https://raw.githubusercontent.com/gAlleb/omvoid/refs/heads/main/boot.sh | bash
```

The installer asks for your password a few times and offers a reboot at the end.

It runs as a list of **steps**, each marked done in
`~/.local/state/omvoid/done/`. A failed run is resumable — just start it again
and completed steps are skipped. The same property makes it safe to re-run later
to pick up steps added since: everything old is skipped, only the new runs.

```bash
bash ~/.local/share/omvoid/install.sh
```

The whole run is logged to `~/.local/state/omvoid/install.log`.

## Installing from an image

The command above turns an existing Void installation into this one. The other
way round is an image that carries everything with it: a small live system, a
mirror of every package omvoid installs, and an installer. Nothing is downloaded
while it runs — a full install takes about twelve minutes, against fifty-four for
the long way, and most of that difference was the same packages being fetched
again on every machine.

The image is **not a snapshot** of a configured system. It partitions the disk,
installs the packages from its own mirror, and then runs this repository's
`install.sh` inside the new system, exactly as the one-line install does. One
description of a machine, not two — a snapshot would have become a second source
of truth and drifted from `install/` without saying so.

### Building one

On any Void machine:

```bash
sudo xbps-install -y xorriso lz4 syslinux squashfs-tools dracut git python3
```

```bash
omvoid-pkg-mirror
```

```bash
omvoid-iso-build -f
```

Both scripts name anything else they need. `omvoid-pkg-mirror` fills
`~/.cache/omvoid/mirror` from Void's repositories and ours; it is a separate step
because it is the moment the image's package versions are chosen.
`omvoid-iso-build` writes the ISO into `~/.cache/omvoid/iso` — `-f` builds a
draft (bigger, quicker), without it a release image (smaller, slower).

The build needs room: about 12 GB free beyond the mirror, since the root tree,
the squashfs and the ISO exist at once. A machine that also carries a full omvoid
desktop will not fit on a 32 GB disk.

### Installing from it

Write the ISO to a stick, boot it, and the installer starts on its own. It asks
everything at the beginning — disk, encryption, hostname, timezone, keymap,
locales, user, git identity, city for the weather, and both passwords — and then
runs to the end without stopping.

Answers are kept in `/tmp/omvoid-install.conf`. Put that file on the medium and
nothing is asked at all, which is how an unattended install is done. Passwords
are never written there and are always asked.

> [!WARNING]
> The installer erases the disk it is given. Installing beside an existing
> system, or into partitions you made yourself, is not supported yet.

To try it in a virtual machine rather than on hardware:

```bash
omvoid-iso-test -n
```

`omvoid-iso-test -b` boots the disk that was installed, without the medium.
`omvoid-iso-screen` takes a picture of the guest and `omvoid-iso-type` types into
it, both through qemu's monitor — useful when a guest fails before it has a
network.

## How long the install takes, and why

Measured, not guessed. The installer times every step and prints the list at the
end; `install.sh` does the same for its own steps and leaves them in
`~/.local/state/omvoid/timings`.

**2026-09-08 — twelve minutes.** On the same machine Omarchy installed in one
minute forty, which is what started the digging.

**2026-09-09 — seven minutes**, after one change:

| | |
|---|---|
| `install.sh` in the chroot | 341 s |
| installing packages | 63 s |
| bootloader, initramfs, boot menu | 18 s |
| everything else | 6 s |

and inside `install.sh`:

| | |
|---|---|
| `development/development.sh` | 211 s |
| `desktop/fonts.sh` | 38 s |
| `desktop/theme.sh` | 34 s |
| `config/swap.sh` | 16 s |
| the other thirty steps | 1-8 s each |

### What was wrong

**The installer tried to work out a package list it did not need.** It called
`omvoid-iso-packages`, a build-machine tool that derives the list from `install/`
with a python parser — and the live system booted from the ISO is a dozen
packages, not a desktop, so it has no python. The call failed without saying so
and the installer preinstalled almost nothing.

Nothing broke: `install.sh` installed the system step by step from the mirror, as
it does on an ordinary install, and only the clock showed anything was odd. The
installer now installs the base and leaves the rest to those steps, deliberately,
so there is no list to work out and nothing on the medium to depend on.

**`xbps-reconfigure -fa` ran the configuration of every package a second time.**
Without `-f` only packages that are *not* configured are processed, and ours are
configured while they are unpacked. The forced pass re-ran every install script
on the system — font caches, icon caches, glib schemas, man-db, the initramfs.
It is now `-a`, with the kernel reconfigured by force on its own so the initramfs
is still rebuilt, and `grub-mkconfig` called explicitly because the boot menu used
to be a side effect of that same pass. Those three together now take 18 seconds.

### What is not wrong

Installing package by package in `install.sh` is not a fault: those steps are the
description of the system and they run on an ordinary install too, where there is
no installer at all. Preinstalling from the medium is an accelerator, and the
steps then find their work already done — an empty transaction costs half a
second.

Nor is the remaining time waste. Some nine hundred packages have to be unpacked,
and that is the work itself.

## What omvoid puts on the EFI partition

Two things, and it matters if the disk carries other systems.

`EFI/OMVOID/grubx64.efi` — the bootloader, in a directory of its own. Every
system on a shared EFI partition keeps its own directory this way; they do not
collide. The firmware finds it through an entry `grub-install` writes into NVRAM.

`EFI/BOOT/BOOTX64.EFI` — the removable fallback, **written only when omvoid
formatted the EFI partition itself**. There is exactly one such path per
partition and the last writer takes it: systemd-boot claims it, and on many
machines it is what boots Windows. On a partition omvoid made, nobody else has
put anything there. On one that already existed, someone may have, so omvoid
leaves it alone.

The fallback exists because the NVRAM entry is not forever. A flat CMOS battery,
a "clear NVRAM" in the firmware menu, a firmware update, or the disk moved to
another machine — and the entry is gone. Nothing looks inside `EFI/OMVOID` by
itself, so a perfectly good system stops booting. The fallback is the path every
firmware tries when it has no entries left.

> [!IMPORTANT]
> **Replacing omvoid with another system?** Its installer will add its own
> directory and, as a rule, will not remove ours. What stays behind is
> `EFI/OMVOID` and, if omvoid formatted this partition, a fallback pointing at
> it. That fallback then leads to a bootloader whose system is gone: with the
> NVRAM entry present nothing changes, but lose it and the machine drops into a
> GRUB rescue prompt instead of booting.
>
> Either let the new installer format the EFI partition, if nothing else lives
> there, or clear ours out by hand:
>
> ```bash
> sudo rm -rf /boot/efi/EFI/OMVOID /boot/efi/EFI/BOOT
> ```
>
> Removing `EFI/BOOT` is safe only when omvoid put it there. If another system
> owns the fallback, delete `EFI/OMVOID` alone.

## What is in it

| | |
|---|---|
| compositor | **mango** (`mangowc`), Wayland, driven by `mmsg` |
| bar, dock | Waybar, crystal-dock, SwayOSD, dunst, wlogout |
| launcher | rofi — applications, wallpapers, themes, clipboard |
| terminals | alacritty, kitty, tmux |
| editor | neovim with NvChad |
| files | nautilus, yazi, ripdrag |
| screen | grim, slurp and satty for shots, wf-recorder for video, awww for wallpaper |
| login | sddm with the astronaut theme |
| audio | pipewire, wireplumber, mpd with rmpc, cava |
| look | WhiteSur GTK/icon/KDE themes, kvantum, qt5ct and qt6ct, nwg-look |
| colour | pywal16 — each theme's palette is computed from its wallpaper and fanned out to the bar, terminal, rofi, GTK and the browser |
| mail | neomutt with mutt-wizard, isync, msmtp, notmuch, pass |
| network | NetworkManager, mihomo with a web interface |
| containers | docker, lazydocker |
| keys | keepassxc, gnome-keyring, seahorse, pam-gnupg |
| agents | claude, codex, copilot, crush, opencode, grok, ori, pi and others — installed on first use through mise, so they cost nothing until they are run |

Ten themes ship with it, and `ALT+W` builds another from any wallpaper.

## Everyday commands

Every command is `omvoid-<verb>-<noun>` and lives in `bin/`, which is on your
PATH straight from the repo — so editing one takes effect immediately.

| | |
|---|---|
| `omvoid-update` | pull the repo, update the system, sync files, run migrations |
| `omvoid-theme-next`, `omvoid-theme-set <name>`, `omvoid-theme-list` | curated themes |
| `omvoid-font-set <name>`, `omvoid-font-list` | change the font everywhere at once |
| `omvoid-menu-keybindings` | every keybinding in a searchable list |
| `omvoid-app-menu` | application launcher (`ALT+O`) |
| `omvoid-launch-tui <cmd>` | open a TUI in a floating window |
| `omvoid-reload-waybar` | reload the bar (`SUPER+W`) |
| `omvoid-toggle-idle`, `omvoid-toggle-waybar` | idle inhibitor, hide the bar |
| `omvoid-cmd-screenshot`, `omvoid-cmd-screenrecord` | capture |
| `omvoid-webapp-install`, `omvoid-tui-install` | add a web app or a TUI to the menu |

`ALT+W` opens the wallpaper picker. Media, volume and brightness keys work as
expected through `swayosd` and `playerctl`.

## Themes and wallpapers

Colour lives in one place: **pywal**. Whatever changes the look ends by running
`wal`, which writes `~/.cache/wal/`. Everything else either imports from there or
is told to reload. There are two ways in.

**`ALT+W` — the wallpaper picker.** Pick an image from `~/.config/wallpaper`,
choose Dark or Light, and the palette is derived from the picture. This is the
one that gives you endless themes. `🎨 Switch Theme` inside it re-runs only the
light/dark half, keeping the current wallpaper.

**Curated themes.** `themes/<name>/` carries a fixed palette, an icon theme and
its own backgrounds. Switch with `omvoid-theme-next` or `omvoid-theme-set <name>`.
Themes are symlinked into `~/.config/omvoid/themes/`, so editing one in the repo
takes effect at once.

Both paths recolour the same set: the bar, the compositor's borders, terminals,
notifications, rofi, the browser, Telegram, GTK and libadwaita apps (Nautilus
included), and Obsidian. Obsidian is coloured through a **snippet**, so whatever
theme you have selected there stays selected.

If you also run [Noctalia](https://github.com/noctalia-dev/noctalia-shell), turn
its GTK and Obsidian options off — otherwise two systems write the same colours
and which one wins is decided by file order rather than by intent.

## Keeping several machines in sync

The repo reaches `$HOME` by **copying**, so `git pull` alone changes nothing
outside `bin/` and `themes/`. `omvoid-update` closes that gap:

```bash
omvoid-update       # asks before replacing anything
omvoid-update -y    # unattended: reports differences, replaces nothing
```

It lists the files that differ from the repo and lets you pick per file. The old
version is kept as `<file>.bak.<epoch>` and the diff is printed.

Your own edits are not on that list. OMVOID remembers what it deployed, so it can
tell the three cases apart: if the repo moved ahead you are offered the new
version, if you edited the live file it stays yours and is never mentioned, and
if both changed it is flagged so you can look. Files rewritten by a program —
your font, `lazy-lock.json`, crystal-dock's state, the real `rclone.conf` — fall
into the second case and disappear from view on their own.

Edits happen on both sides, so there is a way back:

```bash
omvoid-refresh-config --capture mango/conf/windowrules.conf
```

That takes the live file into the repo. Without it, a tweak made in passing on a
live config dies at the next update. Paths may be given repo-relative
(`applications/imv.desktop`, `default/.bashrc`) or, for configs, relative to
`~/.config`.

### Adopting a machine that has drifted

A machine that has been running an older checkout for a while is brought into
line once, by hand. That gives the comparison a truthful starting point;
everything after it is automatic.

```bash
cp -a ~/.config ~/.config.bak-$(date +%F) && omvoid-font-current
```

```bash
cd ~/.local/share/omvoid && git pull
```

```bash
cp -R ~/.local/share/omvoid/config/* ~/.config/
```

```bash
cd ~/.local/share/omvoid/default && cp .bashrc .bash_profile .gtkrc-2.0 ~/ && cp gnupg/gpg-agent.conf ~/.gnupg/ && omvoid-refresh-applications
```

Then run the installer — it skips every step already done and adds the new ones,
recording the starting point as its last act:

```bash
bash ~/.local/share/omvoid/install.sh
```

Only now put your machine-specific files back from the backup — monitor layout,
autostart, `rclone.conf`, and your font with `omvoid-font-set`. Restoring them
*after* the installer is what makes them count as your edits, so they will never
be offered for replacement again. Log out and back in for the new shell files.

## Migrations

The sync can deliver a file. It cannot remove one that is no longer in the repo,
move it, or repair something in place — `git pull` only knows about what exists.
That is what migrations are for.

```bash
omvoid-dev-add-migration "drop walker: removed from omvoid"
omvoid-migrate --pending
```

Each one runs once per machine and is remembered in
`~/.local/state/omvoid/migrations/`. `omvoid-update` runs pending ones for you.
A migration only helps if it is **committed and pushed** — it travels like any
other file in the repo.

## AI coding agents

Agent CLIs are pre-wired as lazy wrappers: the command is on your PATH from first
boot, weighs a couple of hundred bytes, and downloads the real tool the first time
you run it. `claude`, `agy`, `codex`, `opencode`, `crush`, `copilot`, `pi`, `gh`
and others are ready this way.

```bash
omvoid-mise-list                  # what is wrapped, and what has been downloaded
omvoid-mise-install <package>     # wrap another one
omvoid-update-mise                # update everything mise manages
```

A bar module shows how much of your subscription is used — the percentage of the
5-hour and weekly limits, time until they reset, and tokens by day and by model.
It appears only once there is real usage on the machine. Click it to refresh.

The authoritative percentages need a live sign-in, which only the terminal
`claude` refreshes; the token counts come from local transcripts and always work.

OMVOID also ships a **skill** describing itself, symlinked into the skill
directories of Claude Code, Codex, Antigravity and the generic `~/.agents/skills`.
Agents that read it know how this system is put together without being told.

## Adding your own things

**A theme.** Create `themes/<name>/` with `colors.json` (pywal format),
`icons.theme`, `chromium.theme` and a `backgrounds/` folder, then symlink it into
`~/.config/omvoid/themes/`.

**A program that is not packaged.** Drop the executable into
`install/apps/files/`. It is installed to `~/.local/bin` on fresh machines and
offered by `omvoid-update` on existing ones — no new install step needed.

**An install step.** Create `install/<group>/<name>.sh` and add
`run_step <group>/<name>.sh` to `install.sh`. Steps are *sourced*: never call
`exit` from one, it would kill the whole installer.

**A wrapped CLI.** Add a line to `install/development/mise.sh`.

## Where things live

| | |
|---|---|
| `~/.local/share/omvoid` | the repo, also `$OMVOID_PATH` |
| `~/.config/omvoid/current/theme` | symlink to the active theme |
| `~/.config/wallpaper` | wallpapers offered by `ALT+W` |
| `~/.cache/wal/` | generated colours; everything reads from here |
| `~/.local/state/omvoid/done/` | which install steps have run |
| `~/.local/state/omvoid/migrations/` | which migrations have run |
| `~/.local/state/omvoid/install.log` | the installer's log |
| `~/.cache/omvoid_wallpaper/` | wallpaper thumbnails and current-wallpaper state |

## Troubleshooting

**A step needs to run again.** Delete its marker and re-run the installer:

```bash
rm ~/.local/state/omvoid/done/development/mise.sh
```

**The bar is wrong after a config change.** `omvoid-reload-waybar`, or `SUPER+W`.

**Colours did not follow a theme change.** Almost always a missing reload rather
than a hardcoded colour — colours are never written into app configs by hand.

**A theme switch did nothing.** If `wal` fails, the switch stops on purpose and
notifies instead of reloading the compositor against a half-written cache.

**Something crashed and left nothing behind.** Core dumps are off by default on
Void, so there is nothing to look at afterwards. Enable them before you need them.
