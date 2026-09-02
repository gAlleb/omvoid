#!/bin/bash

# mise — менеджер версий и инструментов. Здесь он нужен прежде всего ради
# ленивых обёрток: omvoid-mise-install кладёт в ~/.local/bin файл на несколько
# строк, который ставит инструмент при первом запуске. Команда есть в PATH с
# первой загрузки системы, а установка не удлиняется ни на секунду, сколько бы
# CLI ни было прошито.

sudo xbps-install -y mise

# Node. Раньше ставился через nvm (install/development/node.sh, закомментирован
# целиком): тот качал инсталлятор с github и брал последнюю 22.x, из-за чего на
# двух машинах могли оказаться разные версии. Здесь версия задана явно.
mise use -g node@24

# Ни одна из строк ничего не скачивает: каждая создаёт файл на ~200 байт.
# Имена без префикса разрешаются через реестр mise и приезжают нативными
# бинарниками через бэкенд aqua; префикс нужен только там, где реестр не знает
# пакета (npm:, github:) или где имя команды не совпадает с именем пакета.

# Агентские CLI
omvoid-mise-install claude
omvoid-mise-install agy
omvoid-mise-install codex
omvoid-mise-install copilot
omvoid-mise-install crush
omvoid-mise-install opencode
omvoid-mise-install pi
omvoid-mise-install github:can1357/oh-my-pi omp
omvoid-mise-install github:OpenRouterLabs/ori-releases ori
omvoid-mise-install npm:@xai-official/grok grok

# Прочие инструменты
omvoid-mise-install gh
omvoid-mise-install npm:playwright playwright
omvoid-mise-install npm:@kitlangton/ghui ghui
omvoid-mise-install aqua:modem-dev/hunk hunk
omvoid-mise-install github:basecamp/hey-cli hey

