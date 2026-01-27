#!/bin/bash
CLASS="dash-box"

if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" > /dev/null; then
    hyprctl dispatch closewindow class:$CLASS
    exit 0
fi

hyprctl dispatch exec "kitty --class $CLASS -e /home/$USER/.config/dash/dashboard.sh"
