#!/usr/bin/env python3
"""Модуль waybar: расход агентов одной строкой в баре и разбивкой в подсказке.

Сам ничего не считает -- обновляет записи через omvoid-agent-usage-update и
читает то, что коллекторы положили в ~/.local/state/omvoid/agents/usage/.
"""

import datetime as dt
import json
import os
import subprocess
import sys
from pathlib import Path

BAR_WIDTH = 12


def usage_dir() -> Path:
    root = Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local/state"))
    return root / "omvoid" / "agents" / "usage"


def human(n: int) -> str:
    for limit, suffix in ((1_000_000_000, "B"), (1_000_000, "M"), (1_000, "K")):
        if n >= limit:
            value = n / limit
            return f"{value:.1f}{suffix}" if value < 100 else f"{value:.0f}{suffix}"
    return str(n)


def until(iso: str) -> str:
    raw = (iso or "").strip()
    if not raw:
        return ""
    try:
        moment = dt.datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except Exception:
        return ""
    if moment.tzinfo is None:
        moment = moment.replace(tzinfo=dt.timezone.utc)
    seconds = (moment - dt.datetime.now(dt.timezone.utc)).total_seconds()
    if seconds <= 0:
        return "сброшен"
    days, rest = divmod(int(seconds), 86400)
    hours, minutes = divmod(rest // 60, 60)
    if days:
        return f"через {days} дн {hours} ч"
    if hours:
        return f"через {hours} ч {minutes} мин"
    return f"через {minutes} мин"


def bar(value: float, width: int = BAR_WIDTH) -> str:
    filled = max(0, min(width, round(value * width)))
    return "█" * filled + "░" * (width - filled)


def render(record: dict) -> tuple:
    lines = []
    head = record.get("name") or record.get("id") or "agent"
    plan = record.get("plan") or ""
    lines.append(f"{head}{' · ' + plan if plan else ''}")

    limits = record.get("limits") or []
    worst = -1.0
    if limits:
        lines.append("")
        for limit in limits:
            percent = float(limit.get("percent") or 0)
            worst = max(worst, percent)
            reset = until(str(limit.get("resetsAt") or ""))
            label = str(limit.get("label") or "")
            lines.append(f"{label:<14} {bar(percent)} {percent * 100:4.0f}%  {reset}")

    status = record.get("limitsStatus") or ""
    if status:
        lines.append("")
        lines.append(f"лимиты: {status}")

    today = record.get("today") or {}
    lines.append("")
    lines.append(f"Сегодня: {human(today.get('tokens', 0))} токенов, {today.get('messages', 0)} сообщений")
    lines.append(
        f"  ввод {human(today.get('input', 0))}"
        f" · вывод {human(today.get('output', 0))}"
        f" · кэш чт. {human(today.get('cacheRead', 0))}"
        f" / зап. {human(today.get('cacheWrite', 0))}"
    )

    days = record.get("recentDays") or []
    if days:
        peak = max((day.get("tokens", 0) for day in days), default=0) or 1
        lines.append("")
        lines.append(f"За 7 дней: {human(record.get('weekTokens', 0))}")
        for day in days:
            date = str(day.get("date") or "")
            label = f"{date[8:10]}.{date[5:7]}"
            tokens = day.get("tokens", 0)
            lines.append(f"  {label}  {bar(tokens / peak, 10)} {human(tokens):>7}")

    models = record.get("byModel") or []
    if models:
        lines.append("")
        lines.append("Модели за неделю:")
        for item in models[:5]:
            lines.append(f"  {str(item.get('model') or ''):<22} {human(item.get('tokens', 0)):>7}")

    return "\n".join(lines), worst


def main() -> int:
    # Обновляем данные сами: waybar дёргает этот скрипт по своему интервалу, и
    # отдельный таймер ради того же самого был бы лишней сущностью.
    try:
        bin_dir = Path(os.environ.get("OMVOID_PATH") or (Path.home() / ".local/share/omvoid")) / "bin"
        subprocess.run(
            [str(bin_dir / "omvoid-agent-usage-update")],
            timeout=30,
            capture_output=True,
        )
    except Exception:
        pass  # показываем то, что уже лежит

    records = []
    directory = usage_dir()
    if directory.is_dir():
        for path in sorted(directory.glob("*.json")):
            try:
                records.append(json.loads(path.read_text(encoding="utf-8")))
            except Exception:
                continue

    if not records:
        # Ни одного агента -- модуль не занимает место в баре.
        print(json.dumps({"text": "", "tooltip": "", "class": "empty"}))
        return 0

    tooltips = []
    parts = []
    worst = -1.0
    for record in records:
        text, limit = render(record)
        tooltips.append(text)
        worst = max(worst, limit)
        # На агента -- своя доля. Процент до лимита авторитетнее токенов: он
        # приходит от провайдера, а не считается из транскриптов.
        if limit >= 0:
            parts.append((record.get("id") or "?", f"{limit * 100:.0f}%"))
        else:
            parts.append((record.get("id") or "?", human(int((record.get("today") or {}).get("tokens") or 0))))

    # С одним агентом имя в баре лишнее -- и так понятно, чьё число. С двумя и
    # больше без имени не разобрать, какой из процентов чей.
    if len(parts) == 1:
        text = f"󰚩 {parts[0][1]}"
    else:
        text = "󰚩 " + " · ".join(f"{name} {value}" for name, value in parts)

    if worst >= 0.95:
        css = "critical"
    elif worst >= 0.8:
        css = "warning"
    elif worst >= 0:
        css = "ok"
    else:
        css = "local"

    print(json.dumps({
        "text": text,
        "tooltip": "\n\n".join(tooltips).replace("&", "&amp;").replace("<", "&lt;"),
        "class": css,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
