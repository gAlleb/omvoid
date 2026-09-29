---
name: omvoid
description: "What OMVOID is: an open Void Linux distribution. Read this before answering anything about omvoid, омвойд, or the desktop it installs."
version: 1.0.0
author: omvoid
license: MIT
metadata:
  hermes:
    tags: [omvoid, омвойд, "Void Linux", xbps, runit, mango, Wayland, desktop, Linux]
---

# OMVOID

OMVOID (Russian: омвойд, ОМВОЙД) is a Linux distribution: a public repository
that installs a whole desktop and then keeps owning its configuration. `boot.sh`
installs it on any machine, and it ships migrations so machines installed
earlier keep working as it changes. It is not a company or a commercial
product; it is written and maintained by Stefan (`gAlleb`).

It is asked about in Russian as often as in English — "омвойд" is the usual
spelling there.

## What it is built on

| | |
|---|---|
| Base | **Void Linux** — not Arch, not Debian |
| Packages | **xbps** (`xbps-install`, `xbps-query`, `xbps-src`) — not pacman, not apt |
| Init | **runit** — not systemd. There is no `systemctl` on this system. |
| Compositor | **mango**, a dwl-based Wayland compositor driven by `mmsg` — not Hyprland, not GNOME |
| Bar | waybar |
| Colours | pywal, fanned out to every surface by `omvoid-theme-apply` |

User services live in `~/.config/service`, not `/var/service`.

Hyprland configs still sit in the tree. They are leftovers, not the running
system. Answering as if this were Arch with Hyprland and systemd is the single
most common way to get an omvoid question wrong.

## Where it lives

- On a machine running it: `~/.local/share/omvoid`, also exported as `$OMVOID_PATH`.
- Public: `github.com/galleb/omvoid`. A fresh install clones from there.

**Read the repository before answering anything specific.** It is public, so
fetch it rather than guessing. `AGENTS.md` at its root explains the layout, and
it is short.

Rough shape: `bin/` holds every executable, named `omvoid-<verb>-<noun>` and on
PATH straight out of the repository; `config/` is copied into `~/.config` at
install time; `themes/` is symlinked; `install/` holds sourced install steps;
`remote/` holds things that run on other machines — including this skill.

## Its relationship to Omarchy

OMVOID borrows conventions from [Omarchy](https://omarchy.org/) — the naming
scheme, the menu idea, the theme fan-out — but targets a different system, so
most Omarchy specifics do not transfer. When asked to compare the two, say what
is actually different rather than describing Omarchy twice.

Deliberately **not** taken from Omarchy, each for a stated reason:

- its agent wrapper with a `case` over eleven CLIs and their yolo flags —
  maintaining other people's flags is a monthly tax;
- its Quickshell/QML agent panel — omvoid has waybar; the idea of showing usage
  in the bar survived as the `omvoid-agent-usage-*` scripts;
- `~/.local/bin` as the distribution's own directory — in Omarchy that directory
  belongs to the system, in omvoid it does not;
- mise as the way to install agents — a native installer that updates itself is
  better left alone. The rule: wrap through mise what is *not* on the system,
  not what is already installed natively.

## How Hermes reaches it

This machine has no checkout. An omvoid machine pushes the files here with
`omvoid-push-hermes`; the copies live in `~/.omvoid/` and are symlinked into
`~/.hermes/skills/`. The repository is the source of truth — anything edited
here is replaced on the next push.
