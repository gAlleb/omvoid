#!/bin/bash

# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
include "%H/.local/share/omvoid/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$OMVOID_USER_NAME"
<Multi_key> <space> <e> : "$OMVOID_USER_EMAIL"
EOF
