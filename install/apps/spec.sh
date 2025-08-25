#!/bin/bash

tee ~/.local/bin/spec <<'EOF'
#!/bin/bash

# spec - Copyright (c) 2024 Matthias C. Hormann
# 2024-03-26
# Show spectrogram for an audio file, using ffmpeg's showspectrumpic
# Add this to the "Open with…" context menu of your file manager!

# define me
me=`basename "$0"`
version="0.2"

if [ -z "$1" ] ; then
  exit 1;
fi

# Create temporary file names to use.
# kludge for MacOS: Mac variant first, then Linux:
TEMP=`mktemp -u -t ${me} 2>/dev/null || mktemp -u -t ${me}-XXXXXXXXXX`
TEMPIMG="${TEMP}.png"
TEMPTXT="${TEMP}.txt"

# Shell + ffmpeg quoting rules are a mess, and inconsistent,
# so better use a temporary text file for the info.
# Save the original file name to show in the spectrogram.
basename "$1" > "${TEMPTXT}"

# Note: showspectrumpic height MUST be a power of 2!
ffmpeg -v quiet -y -i "$1" -filter_complex showspectrumpic=s=1024x512:stop=22000,drawtext="expansion=none:textfile='${TEMPTXT}':x=(w-tw)/2:y=16:fontcolor='white':fontsize=20" "$TEMPIMG"
exitcode=$?
if [ $exitcode -ne 0 ] ; then
  rm "$TEMPTXT"
  exit $exitcode
fi

# Open in your default PNG image file viewer.
# Using a subshell here so we can wait until closed, before removing the temp file
# Macs don’t have `xdg-open`, so use `open` instead. Requires correct file extension.
dummy=$(xdg-open "$TEMPIMG")
rm "$TEMPIMG" "$TEMPTXT"
EOF

chmod +x ~/.local/bin/spec
