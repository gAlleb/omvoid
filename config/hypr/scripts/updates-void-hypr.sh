#!/bin/bash
update_count=$(xbps-install --memory-sync --dry-run --update | grep -Fe update -e install | wc -l)
icon=""
printf "%s %s\n" "$icon" "$update_count"
