#!/bin/bash

#hdd="$(df -h | awk 'NR==5{print $3, $5}')"
#hdd="$(df -h | awk 'NR==5{print $3}')"
#icon=""
#printf "%s %s\\n" "$icon" "$hdd"
hdd_percent="$(df -h | grep ' /$' | awk '{print $5}')"

icon=""

printf "%s %s\n" "$icon" "$hdd_percent"
