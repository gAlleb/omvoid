#!/bin/bash

# install.sh tees all output to a log, which makes stdout/stderr a pipe. gum
# renders its prompt UI to stderr, and a piped (non-tty) stderr corrupts that
# rendering. Send the UI straight to the terminal so input stays readable; the
# entered value still comes back on stdout for command substitution.
export OMVOID_USER_NAME=$(gum input --placeholder "Enter full name for git" --prompt "Name> " 2>/dev/tty)
export OMVOID_USER_EMAIL=$(gum input --placeholder "Enter email address for git" --prompt "Email> " 2>/dev/tty)
export OMVOID_USER_CITY=$(gum input --placeholder "Enter city to show weather report for" --prompt "City> " 2>/dev/tty)
