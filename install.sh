#!/bin/bash
set -e
clear && sleep 0.5
read -p "Continue? (y/N): " -n 1 -r


clear && sleep 0.5
echo "===================================================="
echo "Nude-Hyprland Installation"
echo "===================================================="

#!/bin/bash
set -e

WORKSPACE=$(mktemp -d)
cd "$WORKSPACE"

echo "Installing Rice..."

git clone --quiet --depth 1 --branch Pastel-Integrated \
    https://github.com/Sobserius/Nude-Hyprland.git source_files

cd source_files

echo "Creating folders..."
mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar

echo "Copying files..."
cp colors.conf ~/.config/themes/ 2>/dev/null || true
cp dashboard.sh ~/.config/dash/ 2>/dev/null || true
cp hypridle.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprland.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock-colors.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock.conf ~/.config/hypr/ 2>/dev/null || true
cp launcher.sh ~/.config/dash/ 2>/dev/null || true
cp picker.sh ~/.config/themes/tools/ 2>/dev/null || true
cp style.css ~/.config/waybar/ 2>/dev/null || true
cp screenshot.sh ~/.config/dash/ 2>/dev/null || true
cp config ~/.config/waybar/ 2>/dev/null || true
cp sync.sh ~/.config/themes/tools/ 2>/dev/null || true

if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
    echo "Laptop detected"
    cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": [ "clock", "hyprland/language" ],
    "modules-right": ["tray", "network", "wireplumber", "battery"],

    "custom/prompt": {
        "format": "user@hyprland:~$ "
    },
    "hyprland/workspaces": {
        "format": "[{name}]",
        "persistent-workspaces": { "*": 5 }
    },
    "network": {
        "format-wifi": "net: {essid}",
        "format-disconnected": "net: down"
    },
    "bluetooth": {
        "format": "bt: {status}",
        "format-connected": "bt: {device_alias}"
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
    },


    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    }
}
EOF
else
    echo "Desktop PC detected"
    cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": [ "clock", "hyprland/language" ],
    "modules-right": ["tray", "memory", "cpu", "wireplumber"],

    "custom/prompt": {
        "format": "user@hyprland:~$ "
    },
    "hyprland/workspaces": {
        "format": "[{name}]",
        "persistent-workspaces": { "*": 5 }
    },
    "network": {
        "format-wifi": "net: {essid}",
        "format-disconnected": "net: down"
    },
    "bluetooth": {
        "format": "bt: {status}",
        "format-connected": "bt: {device_alias}"
    },
   "wireplumber": {
        "format": "vol: {volume}%",
        "format-muted": "vol: MUTED",
        "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "tooltip-format": "Volume: {volume}%\nMuted: {mute}"
    },

    "cpu": {
        "format": "cpu: {}%"
    },

    "memory": {
        "format": "mem: {}%"
    },

    "hyprland/language": {
        "format": "{}"
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    },


    "custom/launcher": {
        "format": "○",
        "on-click": "if hyprctl clients | grep -q 'class: dash-box'; then hyprctl dispatch closewindow class:dash-box; else ~/.config/dash/launcher.sh; fi",
        "tooltip": false
    }
}
EOF
fi
chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true

cd /
rm -rf "$WORKSPACE"
echo "File deployment is complete."
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
