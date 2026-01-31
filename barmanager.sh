#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
CONFIGS_DIR="$WAYBAR_DIR/configs"
CURRENT_CONFIG="$WAYBAR_DIR/config"

mkdir -p "$CONFIGS_DIR"

create_defaults() {
    [ ! -f "$CONFIGS_DIR/Default.json" ] && cat > "$CONFIGS_DIR/Default.json" << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock", "hyprland/language"],
    "modules-right": ["tray", "network", "wireplumber", "battery"],
    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "[{name}]",
        "persistent-workspaces": { "*": 5 }
    },
    "network": {
        "format-wifi": "net: {essid}",
        "format-disconnected": "net: down"
    },
    "wireplumber": {
        "format": "vol: {volume}%",
        "format-muted": "vol: MUTED",
        "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "tooltip-format": "Volume: {volume}%\nMuted: {mute}"
    },
    "battery": {
        "format": "bat: {capacity}%"
    },
    "hyprland/language": {
        "format": "{}"
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    }
}
EOF

    [ ! -f "$CONFIGS_DIR/PC.json" ] && cat > "$CONFIGS_DIR/PC.json" << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock", "hyprland/language"],
    "modules-right": ["tray", "network", "wireplumber", "cpu", "memory"],
    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "[{name}]",
        "persistent-workspaces": { "*": 5 }
    },
    "network": {
        "format-wifi": "net: {essid}",
        "format-disconnected": "net: down"
    },
    "wireplumber": {
        "format": "vol: {volume}%",
        "format-muted": "vol: MUTED",
        "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "tooltip-format": "Volume: {volume}%\nMuted: {mute}"
    },
    "cpu": {
        "format": "cpu: {usage}%",
        "interval": 2
    },
    "memory": {
        "format": "mem: {percentage}%",
        "interval": 2
    },
    "hyprland/language": {
        "format": "{}"
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    }
}
EOF

    [ ! -f "$CONFIGS_DIR/Laptop.json" ] && cat > "$CONFIGS_DIR/Laptop.json" << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "network", "wireplumber", "backlight", "battery"],
    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "[{name}]",
        "persistent-workspaces": { "*": 5 }
    },
    "network": {
        "format-wifi": "net: {essid}",
        "format-disconnected": "net: down"
    },
    "wireplumber": {
        "format": "vol: {volume}%",
        "format-muted": "vol: MUTED",
        "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "tooltip-format": "Volume: {volume}%\nMuted: {mute}"
    },
    "backlight": {
        "device": "intel_backlight",
        "format": "bright: {percent}%"
    },
    "battery": {
        "format": "bat: {capacity}%"
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    }
}
EOF

    [ ! -f "$CONFIGS_DIR/Minimal.json" ] && cat > "$CONFIGS_DIR/Minimal.json" << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher"],
    "modules-center": ["clock"],
    "modules-right": ["wireplumber"],
    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    },
    "wireplumber": {
        "format": "vol: {volume}%",
        "format-muted": "vol: MUTED",
        "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "tooltip-format": "Volume: {volume}%\nMuted: {mute}"
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    }
}
EOF
}

preview_config() {
    local file="$1"
    echo -e "\n"
    
    echo -e "\nMODULES:"
    echo "--------"
    grep -o '"[^"]*":\s*{' "$file" 2>/dev/null | sed 's/"//g; s/: {//' | while read -r module; do
        echo "  - $module"
    done | head -10
}

export -f preview_config

create_defaults

CHOICE=$(ls -1 "$CONFIGS_DIR"/*.json 2>/dev/null | xargs -n1 basename | sed 's/\.json$//' | fzf \
    --reverse \
    --no-sort \
    --info=hidden \
    --prompt="CHOOSE > " \
    --preview="bash -c 'preview_config $CONFIGS_DIR/{}.json'" \
    --preview-window="right:50%:border-left" \
    --bind "ctrl-n:execute(bash -c 'create_new_config')")

if [ -n "$CHOICE" ]; then
    ln -sf "$CONFIGS_DIR/$CHOICE.json" "$CURRENT_CONFIG"
    pkill -USR2 waybar
    sleep 1
fi
