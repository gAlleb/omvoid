#!/bin/bash

omvoid_migrations_state_path=~/.local/state/omvoid/migrations
mkdir -p $omvoid_migrations_state_path

for file in ~/.local/share/omvoid/migrations/*.sh; do
  touch "$omvoid_migrations_state_path/$(basename "$file")"
done
