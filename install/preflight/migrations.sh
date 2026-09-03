#!/bin/bash

# Помечает все существующие миграции как выполненные -- но только на честно
# свежей установке.
#
# Смысл: машина, собранная из текущего репозитория, уже собрана правильно, и
# исторические починки ей не нужны. А вот на машине, где omvoid стоит давно,
# штамповать нельзя: install.sh там запускают, чтобы подхватить новые шаги, и
# он молча пометил бы невыполненные миграции выполненными -- то есть отменил бы
# ровно то, ради чего миграции и заводятся.
#
# Отличаем по маркерам шагов: этот шаг идёт в install.sh первым, поэтому на
# свежей машине их ещё нет ни одного.

omvoid_done_path=~/.local/state/omvoid/done
omvoid_migrations_state_path=~/.local/state/omvoid/migrations

if [ -d "$omvoid_done_path" ] && [ -n "$(find "$omvoid_done_path" -type f -print -quit 2>/dev/null)" ]; then
  echo "не свежая установка -- миграции не штампую, их выполнит omvoid-migrate"
else
  mkdir -p "$omvoid_migrations_state_path"
  for file in ~/.local/share/omvoid/migrations/*.sh; do
    # Пустой каталог: шаблон остаётся неразвёрнутым, и без этой проверки
    # создался бы маркер с именем "*.sh".
    [ -f "$file" ] || continue
    touch "$omvoid_migrations_state_path/$(basename "$file")"
  done
fi
