#!/bin/bash

# Раскладывает в ~/.local/bin всё, что лежит в install/apps/files.
#
# Это место для программ, которых нет в репозиториях Void и которые не ставятся
# обёрткой mise -- их приходится носить с собой. Сейчас там netui, curses-фронтенд
# к NetworkManager: на него ссылается модуль сети в waybar
# ("on-click": "omvoid-launch-tui netui"), ему нужны python3 и nmcli.
#
# Папкой, а не по файлу: добавил программу в install/apps/files -- она поедет
# на все машины сама, без правки этого шага. Обновление подхватывает их так же
# (см. список каталогов развёртывания в omvoid-update).
#
# В отличие от spec и audiometer, встроенных heredoc'ом в install/apps/audioutils.sh,
# эти лежат отдельными файлами: в netui 2258 строк, внутри install-скрипта их
# было бы не прочитать и не поправить.

for tool in ~/.local/share/omvoid/install/apps/files/*; do
  [[ -f $tool ]] || continue
  install -Dm755 "$tool" ~/.local/bin/"$(basename "$tool")"
done
