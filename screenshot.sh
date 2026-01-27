#!/bin/bash

FILE="/tmp/screenshot_check.png"
rm -f "$FILE"
pkill slurp

hyprpicker -r -z &
PICKER_PID=$!
sleep 0.1
grim -g "$(slurp -d)" "$FILE"

kill $PICKER_PID

if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
    notify-send "Screenshot" "Region captured" -i camera-photo -r 99
    rm "$FILE"
else
    notify-send "Screenshot" "Selection cancelled" -i dialog-information -r 99
fi
