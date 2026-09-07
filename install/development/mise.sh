#!/bin/bash

# mise — менеджер версий и инструментов. Здесь он нужен прежде всего ради
# ленивых обёрток: omvoid-mise-install кладёт в ~/.local/bin файл на несколько
# строк, который ставит инструмент при первом запуске. Команда есть в PATH с
# первой загрузки системы, а установка не удлиняется ни на секунду, сколько бы
# CLI ни было прошито.

sudo xbps-install -y mise

# Node. It used to come from nvm (install/development/node.sh, commented out
# entirely): that fetched its installer from github and took the latest 22.x, so
# two machines could end up on different versions. Here the version is explicit.
#
# A stub like everything else below, not "mise use -g node@24": that one
# downloads, and installing from the medium there is no network to download
# from. Trying to write just the version pin instead does not work either --
# "mise config set" refuses when the config file does not exist yet, which is
# exactly the case on a fresh machine. The stub needs no network at all: it
# pins node@24 and fetches it the first time node is actually run.
# node, and the commands that ship inside the same package. Without their own
# stubs only "node" exists before the first run -- "npm" is simply not found,
# which is not what "node is installed" means to anyone. All four point at the
# same node@24, so the first one used installs it and the rest are then there.
omvoid-mise-install node@24
omvoid-mise-install node@24 npm
omvoid-mise-install node@24 npx
omvoid-mise-install node@24 corepack

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

