#!/bin/bash

# NetBird client -- not in Void repos, built from srcpkgs/netbird into
# omvoid-repo. The package ships the runit service in /etc/sv/netbird and it is
# NOT enabled here: a machine joins a NetBird network deliberately, not because
# omvoid was installed on it.
#
# To turn it on:
#   omvoid-service-enable netbird
#   sudo netbird up --management-url https://nb.sxvx.ru
#
# On Linux NetBird routes stay below directly connected networks (ip rule 105,
# "main table first, except the default route"), so a laptop moving between
# home and office needs no switching: the network it is plugged into wins.

sudo xbps-install -y netbird
