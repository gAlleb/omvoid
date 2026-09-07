# Services on Void: runit

Void has no systemd. Services are directories, supervision is a process that
watches them, and enabling one is a symlink. Nothing is generated, nothing is
compiled, and there is no unit file to write.

## The three places

| | |
|---|---|
| `/etc/sv/<name>/` | every service the machine *has* — 79 here |
| `/etc/runit/runsvdir/default/` | the ones that are *enabled* — 32 here. A symlink per service |
| `/var/service/` | where `sv` looks. **Not a directory** |

`/var/service` is the end of a chain, and the middle of it lives in a tmpfs:

    /var/service            -> ../run/runit/runsvdir/current
    /run/runit/runsvdir/current -> /etc/runit/runsvdir/current   (tmpfs, made at boot)
    /etc/runit/runsvdir/current -> default

On a running machine all three names lead to the same place, which is why
`ln -s /etc/sv/foo /var/service` is the usual advice and works.

**It does not work in a system being installed.** `/run` is empty there — the
tmpfs is created by boot, and a chroot has not booted. The link is written into
nothing, the command succeeds, and the installed machine comes up with no
services at all: no network, no display manager, nothing. This is not
hypothetical; it is what omvoid's first image-installed machine did.

So omvoid enables services through `omvoid-service-enable`, which links into
`/etc/runit/runsvdir/default` — the real directory, correct in both cases.

## A service directory

    /etc/sv/dbus/
      run          the script that execs the daemon in the foreground
      check        optional: exit 0 when the service is really ready
      log/         optional: its own run script, usually feeding svlogd
      supervise/   runtime state, created by runsv. Never in git

`run` must **exec** the daemon and it must **not** fork: runit supervises the
process it started. A daemon that daemonises is a service runit will restart
forever.

## Commands

    sv status foo        one service
    sv up foo            start, and keep it up
    sv down foo          stop, and keep it down
    sv restart foo
    sv -w 30 restart foo wait up to 30s for it to come back
    ls /var/service      what is enabled and supervised

`runsvdir` notices a new symlink within a few seconds — there is nothing to
reload. Removing the symlink stops supervision but does **not** stop a running
process: `sv down foo` first, then unlink.

## Traps

- **Enabling in a chroot** — see above. Use `omvoid-service-enable`.
- **A dangling `supervise/`** — a service copied from another machine with its
  `supervise/` directory carries stale state. Delete it before enabling.
- **`sv` needs the service enabled**, not merely present: `sv up foo` on a
  service with no symlink answers "fail: foo: unable to change to service
  directory".
- **User services are a different tree.** omvoid's per-user services live under
  `config/sv_runsvdir_local/` and `config/sv_turnstile/`, supervised by the
  user's own runsvdir, not this one.
