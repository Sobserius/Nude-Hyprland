#!/bin/bash
# ~/.config/themes/preview.sh


THEME_FILE="$1"
SOCKET="$2"

# Extract BG and FG
BG=$(grep -i "^background" "$THEME_FILE" | awk '{print $NF}' | tr -d "[:space:]:\"'#")
FG=$(grep -i "^foreground" "$THEME_FILE" | awk '{print $NF}' | tr -d "[:space:]:\"'#")


kitten @ --to "$SOCKET" set-colors -m state:focused "background=#$BG" "foreground=#$FG"
