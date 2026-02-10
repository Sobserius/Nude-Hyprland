#!/bin/bash

PALETTES_DIR="$HOME/.config/themes/palettes"
TARGET="$HOME/.config/themes/colors.conf"
SYNC_SCRIPT="$HOME/.config/themes/sync_theme.sh"

cleanup() {
    printf "\033]110\007\033]111\007" > /dev/tty
    [[ -f "$SYNC_SCRIPT" ]] && bash "$SYNC_SCRIPT" > /dev/null 2>&1
}
trap cleanup EXIT

apply_preview() {
    local file="$1"
    [[ ! -f "$file" ]] && return
    local bg=$(grep -i "^background" "$file" | grep -oE '[0-9a-fA-F]{6}' | head -1)
    local fg=$(grep -i "^foreground" "$file" | grep -oE '[0-9a-fA-F]{6}' | head -1)
    [[ -n "$bg" ]] && printf "\033]11;#%s\007" "$bg" > /dev/tty
    [[ -n "$fg" ]] && printf "\033]10;#%s\007" "$fg" > /dev/tty
}

show_colors() {
    local file="$1"
    [[ ! -f "$file" ]] && return

    declare -A c
    local bg_hex=""
    
    while read -r line; do
        if [[ "$line" =~ ^color([0-9]+) ]]; then
            local num=$((10#${BASH_REMATCH[1]}))
            local val=$(echo "$line" | grep -oE '[0-9a-fA-F]{6}' | head -1)
            [[ -n "$val" ]] && c[$num]="$val"
        elif [[ "$line" =~ ^background ]]; then
            bg_hex=$(echo "$line" | grep -oE '[0-9a-fA-F]{6}' | head -1)
        fi
    done < <(grep -E "^(color|background)" "$file")
    
    local cols=${FZF_PREVIEW_COLUMNS:-40}
    local title=$(basename "$file" .conf | tr '[:lower:]' '[:upper:]')
    
    local mode="DARK MODE"
    [[ "${bg_hex:0:1}" =~ [89a-fA-F] ]] && mode="LIGHT MODE"

    echo -e "\n\n"
    printf "%*s\n" $(( (${#title} + cols) / 2 )) "$title"
    printf "%*s\n\n" $(( (${#mode} + cols) / 2 )) "$mode"

    local pad=$(( (cols - 24) / 2 ))
    for row in 0 8; do
        printf "%*s" $pad ""
        for col in {0..7}; do
            local idx=$((row + col))
            local hex="${c[$idx]}"
            if [[ -n "$hex" && ${#hex} -eq 6 ]]; then
                local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
                printf "\e[48;2;%d;%d;%dm   \e[0m" "$r" "$g" "$b"
            else
                printf "\e[4${idx}m   \e[0m"
            fi
        done
        echo
    done
}

export -f apply_preview show_colors

CHOICE=$(ls -t "$PALETTES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/\.conf$//' | fzf \
    --reverse --no-sort --info=hidden --prompt="CHOOSE > " \
    --preview="bash -c 'show_colors $PALETTES_DIR/{}.conf'" \
    --preview-window="right:50%:border-left" \
    --bind "focus:execute-silent(bash -c 'apply_preview $PALETTES_DIR/{}.conf')")

[[ -n "$CHOICE" ]] && {
    SELECTED="$PALETTES_DIR/$CHOICE.conf"
    touch "$SELECTED"
    cat "$SELECTED" > "$TARGET"
}
