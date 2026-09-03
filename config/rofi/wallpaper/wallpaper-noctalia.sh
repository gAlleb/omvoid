#!/usr/bin/env bash

# --- 1. Find Current Wallpaper Path ---
WALLPAPER=""

# Check Noctalia environment variable
if [[ -n "$NOCTALIA_WALLPAPER_PATH" && -f "$NOCTALIA_WALLPAPER_PATH" ]]; then
    WALLPAPER="$NOCTALIA_WALLPAPER_PATH"
fi

# Fallback: Check script argument ($1)
if [[ -z "$WALLPAPER" && -n "$1" && -f "$1" ]]; then
    WALLPAPER="$1"
fi

# Exit if no valid wallpaper was found
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    echo "No valid wallpaper found." >&2
    exit 1
fi

# --- 2. Setup Paths and Cache Dirs ---
CACHE_DIR="$HOME/.cache/omvoid_wallpaper"
WALLPAPER_DIR="$HOME/.config/wallpaper"
CURRENT_WALLPAPER_PATH_FILE="${CACHE_DIR}/current_wallpaper_path"

mkdir -p "${CACHE_DIR}/thumbnails"
mkdir -p "$HOME/.config/dunst"

# --- 3. Light / Dark Mode Check & GTK/Kvantum Themes ---
CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")

if [[ "$NOCTALIA_THEME_MODE" == "light" || "$CURRENT_SCHEME" == "prefer-light" ]]; then
    wal_flags="-l -i ${WALLPAPER}"
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
    kvantummanager --set WhiteSur-opaque 2>/dev/null
else
    wal_flags="-i ${WALLPAPER}"
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-grey-dark"
    kvantummanager --set WhiteSur-opaqueDark 2>/dev/null
fi

# --- 4. Run Pywal ---
wal -c
wal ${wal_flags}
wal_status=$?

# Если wal упал, дальше идти нельзя: ниже стоит перезагрузка конфига
# композитора, а он читает то, что wal должен был сгенерировать. Именно так
# опечатка в шаблоне однажды уронила всю сессию.
if (( wal_status != 0 )); then
  echo "wal завершился с ошибкой ($wal_status) -- пропускаю перезагрузку конфигов" >&2
  notify-send -u critical "Тема не применена" "wal упал, см. вывод" 2>/dev/null || true
  exit 1
fi

# --- 5. Wallpaper Setter (awww) ---
awww img "${WALLPAPER}" 2>/dev/null

# --- 6. Update Applications & Colors ---
pywalfox update 2>/dev/null &
omvoid-theme-set-browser wal 2>/dev/null &
omvoid-theme-set-gtk 2>/dev/null
omvoid-theme-set-obsidian 2>/dev/null
echo "\$wallpaper = ${WALLPAPER}" > "$CACHE_DIR/wallpaper-hyprland.conf"

# Notification daemons & status bars
pkill -SIGUSR2 waybar 2>/dev/null
swaync-client -rs 2>/dev/null
makoctl reload 2>/dev/null
mmsg dispatch reload_config

if [ -f "$HOME/.cache/wal/dunstrc" ]; then
    ln -sf "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"
    dunstctl reload 2>/dev/null
    pkill -e --signal SIGKILL dunst 2>/dev/null
fi

wal-telegram --wal 2>/dev/null &

# --- 7. Generate Thumbnail & Cache Files ---
relative_path="${WALLPAPER#${WALLPAPER_DIR}/}"
selected_thumbnail_path="${CACHE_DIR}/thumbnails/${relative_path%.*}.png"

mkdir -p "$(dirname "${selected_thumbnail_path}")"

if command -v magick &>/dev/null; then
    magick "${WALLPAPER}" -thumbnail '320x180>' "${selected_thumbnail_path}" 2>/dev/null
    magick "${WALLPAPER}" "$HOME/.config/bg.jpg" 2>/dev/null
fi

echo "\$wallpaper_thumbnail = $selected_thumbnail_path" > "$CACHE_DIR/wallpaper_thumbnail"
echo "inputbar { background-image: url(\"$selected_thumbnail_path\", height); }" > "$CACHE_DIR/wallpaper_thumbnail.rasi"

# --- 8. Docks & OSD Helpers ---
if [ -f "$HOME/.config/nwg-dock-hyprland/reload.sh" ]; then
    "$HOME/.config/nwg-dock-hyprland/reload.sh" &
fi

if [ -f "$HOME/.config/swayosd/launch.sh" ]; then
    "$HOME/.config/swayosd/launch.sh" &
fi

echo "${WALLPAPER}" > "${CURRENT_WALLPAPER_PATH_FILE}"
