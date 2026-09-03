#!/bin/bash

# netui -- curses-фронтенд к NetworkManager. На него ссылается модуль сети в
# waybar: "on-click": "omvoid-launch-tui netui".
#
# В отличие от spec и audiometer, которые встроены heredoc'ом прямо в
# install/apps/audioutils.sh, netui лежит отдельным файлом: в нём 2258 строк,
# и внутри install-скрипта они были бы нечитаемы и неправимы.
#
# Зависимости: python3 (stdlib curses) и nmcli. ModemManager необязателен --
# нужен только для сведений об операторе и уровне сигнала.

install -Dm755 ~/.local/share/omvoid/install/apps/files/netui ~/.local/bin/netui
