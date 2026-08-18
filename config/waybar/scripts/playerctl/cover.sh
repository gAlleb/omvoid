#!/bin/bash
# Путь к обложке текущего трека для waybar (модуль image#album_art).
#
# ВАЖНО: waybar (SingleImageStrategy) запускает "exec" СИНХРОННО в главном
# GTK-потоке — бар заморожен ровно столько, сколько работает этот скрипт.
# Поэтому скрипт разделён на две части:
#
#   быстрый путь  - только builtin'ы, печатает закешированный путь (~2 мс);
#   --worker      - тот же файл в фоне: playerctl, curl, ресайз, и сигнал
#                   waybar'у только когда обложка реально сменилась.
#
# Логика выбора плеера и fallback на mpd - как в оригинале.

COVER="/tmp/waybar-cover.png"
PATHF="/tmp/waybar-cover.path"
URLF="/tmp/waybar-cover.url"
LOCK="/tmp/waybar-cover.lock"

SELF="${BASH_SOURCE[0]}"

if [ -z "$MUSIC_PLAYING_PLAYERS" ]; then
	MUSIC_PLAYING_PLAYERS="brave chromium firefox spotify ratune de.haeckerfelix.Shortwave strawberry audacious mpd mpv"
fi

# ============================ фоновый воркер ============================
if [ "$1" = "--worker" ]; then
	trap 'rm -rf "$LOCK"' EXIT INT TERM
	mkdir -p "$LOCK" 2>/dev/null   # на случай ручного запуска --worker
	printf '%s' "$$" > "$LOCK/pid" 2>/dev/null

	# Возвращает artUrl первого играющего плеера; иначе - mpd, если он
	# на паузе/остановлен. Порядок перебора - ваш.
	resolve_art() {
		local p mpd_status
		for p in $MUSIC_PLAYING_PLAYERS; do
			if [ "$(playerctl --player="$p" status 2>/dev/null)" = "Playing" ]; then
				playerctl metadata --player="$p" mpris:artUrl 2>/dev/null
				return 0
			fi
		done
		mpd_status=$(playerctl --player=mpd status 2>/dev/null)
		if [ "$mpd_status" = "Paused" ] || [ "$mpd_status" = "Stopped" ]; then
			playerctl metadata --player=mpd mpris:artUrl 2>/dev/null
			return 0
		fi
		return 1
	}

	# Spotify публикует mpris:artUrl отдельным событием, уже ПОСЛЕ смены
	# PlaybackStatus/метаданных. Если плеер играет, а ссылки ещё нет - ждём её,
	# а не пишем пустоту. Мы в фоне, главному потоку это ничего не стоит.
	resolve_art_wait() {
		local art i
		for i in 1 2 3 4 5 6 7 8 9 10; do
			art=$(resolve_art) || return 1   # ничего не играет - ждать нечего
			if [ -n "$art" ]; then
				printf '%s' "$art"
				return 0
			fi
			sleep 0.2
		done
		return 1
	}

work_once() {
	new_path=""
	downloaded=0

	if art=$(resolve_art_wait) && [ -n "$art" ]; then
		if [ "$art" = "$(cat "$URLF" 2>/dev/null)" ] && [ -s "$COVER" ]; then
			# та же самая обложка - на диске уже всё правильно
			new_path="$COVER"
		else
			tmp=$(mktemp "$COVER.XXXXXX") && {
				ok=1
				if [[ $art == http* ]]; then
					curl -sf --max-time 5 "$art" -o "$tmp" || ok=0
				else
					cp "${art/file:\/\//}" "$tmp" 2>/dev/null || ok=0
				fi

				if [ "$ok" = 1 ] && [ -s "$tmp" ]; then
					# уменьшаем один раз здесь, чтобы главный поток
					# декодировал крошечную картинку
					if command -v magick >/dev/null 2>&1; then
						magick "$tmp" -resize 64x64 "$tmp" 2>/dev/null
					elif command -v convert >/dev/null 2>&1; then
						convert "$tmp" -resize 64x64 "$tmp" 2>/dev/null
					fi
					# атомарная подмена - waybar никогда не увидит
					# наполовину записанный файл
					mv -f "$tmp" "$COVER" && {
						printf '%s' "$art" > "$URLF"
						new_path="$COVER"
						downloaded=1
					}
				else
					rm -f "$tmp"
				fi
			}
		fi
	fi

	old_path=""
	[ -f "$PATHF" ] && read -r old_path < "$PATHF"

	if [ "$new_path" != "$old_path" ]; then
		printf '%s\n' "$new_path" > "$PATHF"
	fi

	# Дёргаем waybar только если реально есть что перерисовать.
	# Иначе получилась бы бесконечная петля сигналов.
	if [ "$new_path" != "$old_path" ] || [ "$downloaded" = 1 ]; then
		pkill -RTMIN+10 -x waybar >/dev/null 2>&1
	fi
}

	# Пока воркер занят, быстрый путь не плодит второй, а взводит флаг
	# pending. Досматриваем его здесь, чтобы последнее состояние всегда
	# было снято ПОСЛЕ последнего события, а не в случайный момент.
	while :; do
		rm -f "$LOCK/pending"
		work_once
		[ -f "$LOCK/pending" ] || break
	done

	exit 0
fi

# ==================== быстрый путь (главный поток waybar) ====================
spawn_worker() {
	mkdir "$LOCK" 2>/dev/null || return 0
	# через "$BASH", чтобы не зависеть от бита исполнения на файле
	setsid "${BASH:-/bin/bash}" "$SELF" --worker >/dev/null 2>&1 </dev/null &
}

if [ -d "$LOCK" ]; then
	# воркер уже бежит - просим его сделать ещё круг после текущего
	# (builtin-редирект, без единого форка)
	: > "$LOCK/pending" 2>/dev/null

	# лок остался от умершего воркера - снимаем
	if [ -f "$LOCK/pid" ]; then
		read -r wpid < "$LOCK/pid"
		if [ ! -d "/proc/$wpid" ]; then
			rm -rf "$LOCK"
			spawn_worker
		fi
	fi
else
	spawn_worker
fi

[ -f "$PATHF" ] || exit 0
read -r cover < "$PATHF" || exit 0
[ -n "$cover" ] && [ -f "$cover" ] && printf '%s\n' "$cover"
exit 0
