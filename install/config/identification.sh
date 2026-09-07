#!/bin/bash

# Who this machine belongs to, for git and the weather widget.
#
# Read from the answers the installer already collected, when there are any: on
# an install from the image these questions were asked at the start, and asking
# them a second time here would be a bug the person cannot do anything about.
# Interactively it still asks, which is what a normal install needs.

ANSWERS="$HOME/.local/state/omvoid/install-answers"
if [[ -f $ANSWERS ]]; then
  # shellcheck disable=SC1090
  . "$ANSWERS"
  export OMVOID_USER_NAME="${OMVOID_GIT_NAME:-}"
  export OMVOID_USER_EMAIL="${OMVOID_GIT_EMAIL:-}"
  export OMVOID_USER_CITY="${OMVOID_CITY:-}"
  echo "identification: taken from the installer's answers"
  return 0 2>/dev/null || exit 0
fi

# install.sh tees all output to a log, which makes stdout/stderr a pipe. gum
# renders its prompt UI to stderr, and a piped (non-tty) stderr corrupts that
# rendering. Send the UI straight to the terminal so input stays readable; the
# entered value still comes back on stdout for command substitution.
export OMVOID_USER_NAME=$(gum input --placeholder "Enter full name for git" --prompt "Name> " 2>/dev/tty)
export OMVOID_USER_EMAIL=$(gum input --placeholder "Enter email address for git" --prompt "Email> " 2>/dev/tty)
export OMVOID_USER_CITY=$(gum input --placeholder "Enter city to show weather report for" --prompt "City> " 2>/dev/tty)

# Kept, in the same file the image installer writes. Without this a retry after
# any later failure asks all three questions again, and the answers a person
# gave by hand are worth no less than the ones the installer collected.
#
# Only when something was actually answered. A file full of empty values is read
# back on the next run as "already answered", and the questions would then never
# be asked again on this machine -- worse than having no file at all.
if [[ -n $OMVOID_USER_NAME$OMVOID_USER_EMAIL$OMVOID_USER_CITY ]]; then
  mkdir -p "$(dirname "$ANSWERS")"
  cat >"$ANSWERS" <<EOF
OMVOID_GIT_NAME="$OMVOID_USER_NAME"
OMVOID_GIT_EMAIL="$OMVOID_USER_EMAIL"
OMVOID_CITY="$OMVOID_USER_CITY"
EOF
fi
