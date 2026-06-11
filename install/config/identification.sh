#!/bin/bash

export OMVOID_USER_NAME=$(gum input --placeholder "Enter full name for git" --prompt "Name> ")
export OMVOID_USER_EMAIL=$(gum input --placeholder "Enter email address for git" --prompt "Email> ")
export OMVOID_USER_CITY=$(gum input --placeholder "Enter city to show weather report for" --prompt "City> ")
