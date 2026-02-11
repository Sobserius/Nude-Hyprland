#!/bin/bash

WALLPAPER_DIR="$HOME/Wallpapers"
COLOR_FILE="$HOME/.config/themes/colors.conf"
SYNC_SCRIPT="$HOME/.config/themes/tools/sync.sh"

show_preview() {
    local file="$1"
    [[ ! -f "$file" ]] && return

    printf "\033[2J\033[H"

    local tmp_img="/tmp/fzf_preview_${BASHPID}.jpg"
    magick "$file" -strip -thumbnail 200x200^ -gravity center -extent 200x200 "$tmp_img" 2>/dev/null

    chafa --format symbols --symbols vhalf --size=32x32 "$tmp_img" 2>/dev/null

    local colors=$(magick "$tmp_img" -colors 8 -format "%c" histogram:info: 2>/dev/null | \
                   sort -rn | grep -oE '#[0-9A-Fa-f]{6}' | tr -d '#' | head -n 8 | xargs)

    echo -e "\n"
    echo -ne "  "
    for hex in $colors; do
        printf    " \e[48;2;%d;%d;%dm  "  0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
    done
    rm -f "$tmp_img"
}

export -f show_preview

if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(find "$WALLPAPER_DIR" -maxdepth 1 -name '*.jpg' -o -name '*.png' 2>/dev/null | head -1)" ]; then
    echo "No wallpapers found"
    exit 1
fi

CHOICE=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | \
    xargs -n1 basename | \
    fzf --reverse --no-sort --info=hidden --prompt="WALLPAPER > " \
        --preview="bash -c 'show_preview $WALLPAPER_DIR/{}'" \
        --preview-window="right:50%:border-left")

[[ -n "$CHOICE" ]] && {
    SELECTED="$WALLPAPER_DIR/$CHOICE"

    declare -a COLORS

    if command -v pastel >/dev/null 2>&1; then
        COLORS_STRING=$(pastel distinct -n 24 "$SELECTED" 2>/dev/null | pastel format hex | tr -d '#')
        
        if [ -z "$COLORS_STRING" ]; then
            magick "$SELECTED" -resize 200x200 -colors 24 -format "%c" histogram:info: 2>/dev/null | \
                sort -rn | head -24 | \
                grep -oE '#[0-9A-Fa-f]{6}' | tr -d '#' | xargs
        fi
    else
        COLORS_STRING=$(magick "$SELECTED" -resize 100x100 -colors 16 -format "%c" histogram:info: 2>/dev/null | \
            sort -rn | head -16 | \
            grep -oE '#[0-9A-Fa-f]{6}' | tr -d '#' | xargs)
    fi

    i=0
    for color in $COLORS_STRING; do
        color=$(echo "$color" | grep -o '[0-9A-Fa-f]\{6\}' | head -1)
        if [[ ${#color} -eq 6 ]]; then
            COLORS[$i]="$color"
            ((i++))
            [ $i -eq 16 ] && break
        fi
    done

    while [ ${#COLORS[@]} -lt 16 ]; do
        if [ ${#COLORS[@]} -eq 0 ]; then
            COLORS+=("000000")
        else
            idx=$(( ${#COLORS[@]} % ${#COLORS[@]} ))
            base="${COLORS[$idx]}"
            r=$((0x${base:0:2}))
            g=$((0x${base:2:2}))
            b=$((0x${base:4:2}))
            
            case $(( ${#COLORS[@]} % 3 )) in
                0) r=$(( (r + 20) % 255 ));;
                1) g=$(( (g + 20) % 255 ));;
                2) b=$(( (b + 20) % 255 ));;
            esac
            
            COLORS+=($(printf "%02x%02x%02x" $r $g $b))
        fi
    done

    declare -a BASE_COLORS=(
        "000000" "ff0000" "00ff00" "ffff00" "0000ff" "ff00ff" "00ffff" "ffffff"
        "555555" "ff5555" "55ff55" "ffff55" "5555ff" "ff55ff" "55ffff" "ffffff"
    )

    if command -v pastel >/dev/null 2>&1; then
        DOMINANT_COLOR=$(pastel distinct -n 1 "$SELECTED" 2>/dev/null | pastel format hex | tr -d '#')
        if [ -z "$DOMINANT_COLOR" ]; then
            DOMINANT_COLOR=$(magick "$SELECTED" -resize 100x100 -colors 1 -format "%c" histogram:info: 2>/dev/null | grep -oE '#[0-9A-Fa-f]{6}' | tr -d '#')
        fi
        
        for i in {1..6}; do
            BASE="${BASE_COLORS[$i]}"
            TINTED=$(pastel mix "#$BASE" "#$DOMINANT_COLOR" --fraction 0.6 2>/dev/null | pastel format hex | tr -d '#')
            if [ -n "$TINTED" ]; then
                COLORS[$i]="$TINTED"
            fi
        done
        
        for i in {9..14}; do
            BASE="${BASE_COLORS[$i]}"
            TINTED=$(pastel mix "#$BASE" "#$DOMINANT_COLOR" --fraction 0.6 2>/dev/null | pastel format hex | tr -d '#')
            if [ -n "$TINTED" ]; then
                COLORS[$i]="$TINTED"
            fi
        done
    fi

    if command -v pastel >/dev/null 2>&1; then
        ALL_COLORS_TEMP="/tmp/all_colors_$$.txt"
        
        printf "%s\n" "${COLORS[@]}" | while read -r c; do 
            echo "$c"
        done > "$ALL_COLORS_TEMP"
        
        SORTED_COLORS=$(pastel sort-by brightness "$ALL_COLORS_TEMP" 2>/dev/null)
        
        SORTED_ARR=()
        while IFS= read -r line; do
            SORTED_ARR+=("$line")
        done <<< "$SORTED_COLORS"
        
        if [ ${#SORTED_ARR[@]} -gt 0 ]; then
            bg="${SORTED_ARR[0]}"
            
            BEST_FG=""
            BEST_CONTRAST=0
            
            for color in "${SORTED_ARR[@]}"; do
                if [ "$color" == "$bg" ]; then
                    continue
                fi
                
                contrast=$(pastel contrast "#$bg" "#$color" 2>/dev/null | grep -o '[0-9.]*' | head -1)
                
                if [ -n "$contrast" ] && [ $(echo "$contrast > $BEST_CONTRAST" | bc 2>/dev/null) -eq 1 ]; then
                    BEST_CONTRAST=$contrast
                    BEST_FG="$color"
                fi
            done
            
            if [ -n "$BEST_FG" ]; then
                fg="$BEST_FG"
            else
                if [ ${#SORTED_ARR[@]} -gt 1 ]; then
                    fg="${SORTED_ARR[-1]}"
                else
                    fg="${SORTED_ARR[0]}"
                fi
            fi
            
            contrast=$(pastel contrast "#$bg" "#$fg" 2>/dev/null | grep -o '[0-9.]*' | head -1)
            
            if [ -n "$contrast" ] && [ $(echo "$contrast < 4.5" | bc 2>/dev/null) -eq 1 ]; then
                bg_brightness=$(pastel color "#$bg" 2>/dev/null | grep -o 'brightness: [0-9.]*' | cut -d' ' -f2)
                
                if [ $(echo "$bg_brightness < 0.5" | bc 2>/dev/null) -eq 1 ]; then
                    fg=$(pastel lighten 0.3 "#$fg" 2>/dev/null | pastel format hex | tr -d '#')
                else
                    fg=$(pastel darken 0.3 "#$fg" 2>/dev/null | pastel format hex | tr -d '#')
                fi
            fi
        else
            bg="${COLORS[0]}"
            fg="${COLORS[7]}"
        fi
        
        rm -f "$ALL_COLORS_TEMP"
    else
        bg="${COLORS[0]}"
        fg="${COLORS[7]}"
        
        bg_r=$((0x${bg:0:2}))
        bg_g=$((0x${bg:2:2}))
        bg_b=$((0x${bg:4:2}))
        bg_bright=$(( (bg_r + bg_g + bg_b) / 3 ))
        
        fg_r=$((0x${fg:0:2}))
        fg_g=$((0x${fg:2:2}))
        fg_b=$((0x${fg:4:2}))
        fg_bright=$(( (fg_r + fg_g + fg_b) / 3 ))
        
        if [ $(( fg_bright - bg_bright )) -lt 100 ] && [ $(( fg_bright - bg_bright )) -gt -100 ]; then
            if [ $bg_bright -lt 128 ]; then
                fg=$(printf "%02x%02x%02x" $(( (fg_r * 60 + 255 * 40) / 100 )) $(( (fg_g * 60 + 255 * 40) / 100 )) $(( (fg_b * 60 + 255 * 40) / 100 )))
            else
                fg=$(printf "%02x%02x%02x" $(( (fg_r * 60) / 100 )) $(( (fg_g * 60) / 100 )) $(( (fg_b * 60) / 100 )))
            fi
        fi
    fi

    COLORS[7]="$fg"
    COLORS[15]="$fg"

    cat > "$COLOR_FILE" << EOF
background #$bg
foreground #$fg
color0 #${COLORS[0]}
color1 #${COLORS[1]}
color2 #${COLORS[2]}
color3 #${COLORS[3]}
color4 #${COLORS[4]}
color5 #${COLORS[5]}
color6 #${COLORS[6]}
color7 #${COLORS[7]}
color8 #${COLORS[8]}
color9 #${COLORS[9]}
color10 #${COLORS[10]}
color11 #${COLORS[11]}
color12 #${COLORS[12]}
color13 #${COLORS[13]}
color14 #${COLORS[14]}
color15 #${COLORS[15]}
EOF

    {
        if ! pgrep swww-daemon >/dev/null 2>&1; then
            swww init 2>/dev/null
            sleep 0.3
        fi
        swww img "$SELECTED" --transition-type none 2>/dev/null
    } &

    mkdir -p ~/.config/wallpapers 2>/dev/null
    cp "$SELECTED" ~/.config/wallpapers/current.jpg 2>/dev/null

    if [ -f "$SYNC_SCRIPT" ]; then
        bash "$SYNC_SCRIPT" &
        sleep 0.5
    fi
}
