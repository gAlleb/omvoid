#!/bin/bash

# Mango 0.18 renamed config keys. Rename in place because monitor geometry,
# the autostart list and theme templates can contain machine-specific edits.
set -euo pipefail

# An optional home directory lets the migration be checked on an isolated copy.
python3 - "$@" <<'PY'
from datetime import datetime
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

version = subprocess.check_output(["mango", "-v"], text=True)
match = re.search(r"\b(\d+)\.(\d+)\.(\d+)\b", version)
if not match or tuple(map(int, match.groups())) < (0, 18, 0):
    raise SystemExit("Mango 0.18 or newer is required; update mangowc and retry.")

root = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) > 1 else Path.home()

# Official 0.18.0 migration table:
# https://github.com/user-attachments/files/33058895/migrate-config-keys.sh
renames = dict(pair.split("=") for pair in """
windowrule-once=window_rule_once
windowrule=window_rule
monitorrule=monitor_rule
tagrule=tag_rule
layerrule=layer_rule
devicerule=device_rule
source-optional=source_optional
exec-once=exec_once
keymode=key_mode
isnoborder=no_border
isnoshadow=no_shadow
isnoradius=no_radius
isnoanimation=no_animation
isnosizehint=no_size_hint
noblur=no_blur
noshadow=no_shadow
noanim=no_animation
nofocus=no_focus
nofadein=no_fade_in
nofadeout=no_fade_out
noswallow=no_swallow
special_gappih=special_gap_inner_horizontal
special_gappiv=special_gap_inner_vertical
special_gappoh=special_gap_outer_horizontal
special_gappov=special_gap_outer_vertical
gappih=gap_inner_horizontal
gappiv=gap_inner_vertical
gappoh=gap_outer_horizontal
gappov=gap_outer_vertical
overviewgappi=overview_gap_inner
overviewgappo=overview_gap_outer
default_mfact=default_master_factor
default_nmaster=default_master_count
animation_curve_opafadein=animation_curve_opacity_fade_in
animation_curve_opafadeout=animation_curve_opacity_fade_out
dwindle_hsplit=dwindle_horizontal_split
dwindle_vsplit=dwindle_vertical_split
fadein_begin_opacity=fade_in_begin_opacity
fadeout_begin_opacity=fade_out_begin_opacity
focusdir_only_zone_overlap=focus_direction_only_zone_overlap
force_fakemaximize=force_fake_maximize
idleinhibit_ignore_visible=idle_inhibit_ignore_visible
idleinhibit_when_focus=idle_inhibit_when_focus
idleinhibit_when_fullscreen=idle_inhibit_when_fullscreen
syncobj_enable=sync_obj_enable
isfakefullscreen=is_fake_fullscreen
isfloating=is_floating
isfullscreen=is_fullscreen
isunglobal=is_unmanaged_global
isglobal=is_global
isnamedscratchpad=is_named_scratchpad
isopensilent=is_open_silent
isoverlay=is_overlay
istagsilent=is_tag_silent
isterm=is_term
appid=app_id
bordercolor=border_color
borderpx=border_px
dropcolor=drop_color
focuscolor=focus_color
globalcolor=global_color
globalkeybinding=global_key_binding
maximizescreencolor=maximized_screen_color
mfact=master_factor
nmaster=master_count
numlockon=numlock_on
offsetx=offset_x
offsety=offset_y
overlaycolor=overlay_color
rootcolor=root_color
scratchpadcolor=scratchpad_color
shadowscolor=shadows_color
sloppyfocus=sloppy_focus
smartgaps=smart_gaps
splitcolor=split_color
urgentcolor=urgent_color
warpcursor=warp_cursor
""".split())

directive = re.compile(r"^([ \t]*(?:#[ \t]*)?)([\w-]+)([ \t]*=[ \t]*)(.*)$")
rule_field = re.compile(r"(^|,)([ \t]*)([\w-]+)([ \t]*:)")
rule_types = {"window_rule", "window_rule_once", "monitor_rule", "tag_rule",
              "layer_rule", "device_rule"}


def migrate(text):
    lines = []
    for line in text.splitlines(keepends=True):
        match = directive.match(line)
        if match:
            prefix, key, separator, value = match.groups()
            key = renames.get(key, key)
            if key in rule_types:
                value = rule_field.sub(
                    lambda m: m[1] + m[2] + renames.get(m[3], m[3]) + m[4], value)
            # These symbols can resolve to the same keycode; keep both actions
            # by matching symbols instead of letting Mango report a conflict.
            if key == "bind" and re.match(r"none\s*,\s*XF86Audio(?:Play|Pause)\s*,", value):
                key = "binds"
            line = prefix + key + separator + value + ("\n" if line.endswith("\n") else "")
        lines.append(line)
    return "".join(lines)


config = root / ".config/mango"
template = root / ".config/wal/templates/colors-mango.conf"
cache = root / ".cache/wal/colors-mango.conf"
paths = [config / "config.conf", *sorted((config / "conf").rglob("*.conf")), template, cache]
changes = {}
for path in paths:
    if path.is_file():
        original = path.read_text()
        updated = migrate(original)
        if updated != original:
            changes[path] = updated

if not changes:
    print("Mango configuration already uses 0.18 keys.")
    raise SystemExit(0)

backup = root / ".local/state/omvoid/backups" / datetime.now().strftime("mango-0.18-%Y%m%d-%H%M%S-%f")
backup.mkdir(parents=True, mode=0o700)
for path in changes:
    if path.exists():
        saved = backup / path.relative_to(root)
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, saved)

for path, content in changes.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, prefix=".mango-migrate-", delete=False) as temp:
        temporary = Path(temp.name)
    try:
        if path.exists():
            shutil.copy2(path, temporary)
        temporary.write_text(content)
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)

print(f"Migrated {len(changes)} Mango files. Backup: {backup}")
print("Log out and back in to start programs skipped by the old exec-once directives.")
PY
