#!/bin/bash

COLOR_DIR="$HOME/.config/themes"
DUNST_CONF="$HOME/.config/dunst/dunstrc"
TEMP_BG="$HOME/.cache/current_theme_bg.png"
COLOR_FILE="$HOME/.config/themes/colors.conf"
HYPRLOCK="$HOME/.config/hypr/hyprlock-colors.conf"


sync_theme() {
    SRC="$COLOR_FILE"
    [ ! -f "$SRC" ] && return

    
    BG=$(grep -i "^background" "$SRC" | awk '{print $NF}' | tr -d "[:space:]:\"'" | sed 's/#//g')
    FG=$(grep -i "^foreground" "$SRC" | awk '{print $NF}' | tr -d "[:space:]:\"'" | sed 's/#//g')

    # --- KITTY UPDATE ---
	cp "$COLOR_FILE" "$HOME/.config/kitty/current-theme.conf"
	killall -USR1 kitty
    # --- HYPRLAND BORDERS ---
    cat > ~/.config/hypr/colors.conf <<EOF
misc {
    background_color = 0xff${BG}
}
general {
    col.active_border = 0xff${FG}
    col.inactive_border = 0x66${FG}
}
EOF
    # Apply live so you don't have to wait for a reload
    hyprctl keyword misc:background_color "0xff${BG}" > /dev/null
    hyprctl keyword general:col.active_border "0xff${FG}" > /dev/null
    hyprctl keyword general:col.inactive_border "0x66${FG}" > /dev/null

# --- AUTOMATIC GTK & QT THEME (Dark/Light) ---
FIRST_CHAR=$(echo "${BG#\#}" | cut -c1)

if [[ "$FIRST_CHAR" =~ [89a-fA-F] ]]; then
    # LIGHT MODE
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    flatpak override --user --env=GTK_THEME=adw-gtk3
    
    kvantummanager --set KvFlatLight
    dbus-send --session --dest=org.freedesktop.portal.Desktop --type=method_call /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:'org.freedesktop.appearance' string:'color-scheme'
else
    # DARK MODE
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    flatpak override --user --env=GTK_THEME=adw-gtk3-dark
    
    kvantummanager --set KvFlat
    dbus-send --session --dest=org.freedesktop.portal.Desktop --type=method_call /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:'org.freedesktop.appearance' string:'color-scheme'
fi



    # --- HYPRLOCK COLORS ---
    printf "\$bg = rgb($BG)\n\$fg = rgb($FG)\n\$fg_alpha = rgba(${FG}ee)\n" > "$HYPRLOCK"

    # --- BACKGROUND TASKS (Wallpaper/GTK) ---
    (
        RES=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | "\(.width)x\(.height)"')
        magick -size "${RES:-$RES}" xc:"#$BG" "$TEMP_BG"
        
        ANIM=$(hyprctl -j getoption animations:enabled | jq '.int')
        [ "$ANIM" -eq 1 ] && TRANS="top" || TRANS="none"
        
        swww img "$TEMP_BG" --transition-type "$TRANS" --transition-duration 0.5 --transition-bezier .15,0,.1,1  2>/dev/null
    ) &



    # --- DUNST & WAYBAR ---

    printf "[global]\nbackground=\"#%s\"\nforeground=\"#%s\"\nwidth= 300""\nfont = Monospace 11""\nframe_width = 2""\noffset = (10, 10)""\nframe_color=\"#%s\"\n" "$BG" "$FG" "$FG" > "$DUNST_CONF"
    pkill -HUP dunst || (dunst &)
    echo -e "@define-color bg #$BG;\n@define-color fg #$FG;" > "$HOME/.config/waybar/colors.css"
}

sync_theme
inotifywait -q -m -e close_write "$COLOR_FILE" | while read -r _; do
    sync_theme
done
