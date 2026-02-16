#!/bin/bash
# Get metadata from playerctl
ART_URL=$(playerctl metadata mpris:artUrl 2> /dev/null)
COVER_PATH="/tmp/waybar-cover.png"

# If no art, use a default image or keep it blank
if [ -z "$ART_URL" ]; then
    echo "{\"text\": \"No Art\", \"tooltip\": \"No Art\"}"
    # Optionally echo a blank path or default icon
    exit
fi

# If it's a URL, download it
if [[ $ART_URL == http* ]]; then
    curl -s "$ART_URL" --output "$COVER_PATH"
else
    # If it's a local file (file://), copy it
    cp "${ART_URL/file:\/\//}" "$COVER_PATH"
fi

# Output the path for the image module
echo "$COVER_PATH"

