#!/bin/bash
set -e

# ----------------------------------------------------------------------
# UTILITY FUNCTIONS
# ----------------------------------------------------------------------
die() {
    echo "ERROR: $1" >&2
    exit 1
}

safe_mkdir() {
    mkdir -p "$1"
    chmod 755 "$1"
}

safe_write() {
    local file="$1"
    local content="$2"
    echo "$content" | tee "$file" > /dev/null
    chmod 644 "$file"
}

safe_write_script() {
    local file="$1"
    local content="$2"
    echo "$content" | tee "$file" > /dev/null
    chmod 755 "$file"
}

# ----------------------------------------------------------------------
# INITIAL PROMPT
# ----------------------------------------------------------------------
clear
read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

clear
echo "===================================================="
echo "Nude-Hyprland Installation"
echo "===================================================="

WORKSPACE=$(mktemp -d)
cd "$WORKSPACE"

echo "Installing Rice..."

git clone --quiet --depth 1 --branch Pastel-Integrated \
    https://github.com/Sobserius/Nude-Hyprland.git source_files

cd source_files

# ----------------------------------------------------------------------
# CREATE DIRECTORY STRUCTURE WITH PROPER PERMISSIONS
# ----------------------------------------------------------------------
echo "Creating folders..."
safe_mkdir ~/.config/themes/tools
safe_mkdir ~/.config/dash
safe_mkdir ~/.config/hypr
safe_mkdir ~/.config/dunst
safe_mkdir ~/.config/waybar

# ----------------------------------------------------------------------
# HYPRIAND.CONF CONFIGURATION – SKIPPABLE
# ----------------------------------------------------------------------
echo ""
echo "Hyprland Configuration"
echo "Do you want to install / update hyprland.conf?"
echo "1) Yes – configure keyboard layout (recommended for new installs)"
echo "2) No  – keep existing hyprland.conf (skip completely)"
echo -n "Enter choice [1-2]: "
read hypr_choice

if [ "$hypr_choice" = "1" ]; then
    # Keyboard layout configuration
    echo ""
    echo "Keyboard Layout Configuration"
    echo "1) Single layout (monolingual)"
    echo "2) Multiple layouts (bilingual / multilingual)"
    echo -n "Enter choice [1-2]: "
    read kb_choice

    if [ "$kb_choice" = "1" ]; then
        echo -n "Enter your keyboard layout (default: us): "
        read kb_layout
        [ -z "$kb_layout" ] && kb_layout="us"
        kb_options=""
        layouts_count=1
    else
        echo -n "Enter your keyboard layouts (comma-separated, e.g., us,ru,cz): "
        read kb_layout
        [ -z "$kb_layout" ] && kb_layout="us,ru"
        kb_options="grp:alt_shift_toggle"
        layouts_count=$(echo "$kb_layout" | tr ',' '\n' | wc -l)
    fi

    if [ -f "hyprland.conf" ]; then
        echo "Configuring Hyprland keyboard settings..."
        if [ "$kb_choice" = "1" ]; then
            sed -e "s/kb_layout = us,ru/kb_layout = $kb_layout/" \
                -e '/kb_options = grp:alt_shift_toggle/d' \
                hyprland.conf > ~/.config/hypr/hyprland.conf.tmp
        else
            sed "s/kb_layout = us,ru/kb_layout = $kb_layout/" \
                hyprland.conf | \
            sed "/kb_layout = $kb_layout/a\\
kb_options = $kb_options" \
                > ~/.config/hypr/hyprland.conf.tmp
        fi
        mv ~/.config/hypr/hyprland.conf.tmp ~/.config/hypr/hyprland.conf
        chmod 644 ~/.config/hypr/hyprland.conf
        echo "hyprland.conf updated."
    else
        echo "Warning: hyprland.conf not found in repository – skipping."
    fi
else
    echo "Skipping hyprland.conf configuration. Keeping existing file."
    layouts_count=1  # default to monolingual for Waybar (user can still have multiple layouts, but we don't know)
    # We don't know the user's actual layout count, so we default to monolingual in Waybar.
    # Advanced users can edit Waybar config manually.
fi

# ----------------------------------------------------------------------
# COPY ALL OTHER CONFIGURATION FILES (except hyprland.conf)
# ----------------------------------------------------------------------
echo "Copying other configuration files..."

copy_if_exists() {
    if [ -f "$1" ]; then
        local dest="$2"
        local dest_file="$dest/$(basename "$1")"
        cp "$1" "$dest_file" 2>/dev/null || true
        chmod 644 "$dest_file" 2>/dev/null || true
    fi
}

copy_if_exists colors.conf ~/.config/themes/
copy_if_exists dashboard.sh ~/.config/dash/
copy_if_exists hypridle.conf ~/.config/hypr/
copy_if_exists hyprlock-colors.conf ~/.config/hypr/
copy_if_exists hyprlock.conf ~/.config/hypr/
copy_if_exists launcher.sh ~/.config/dash/
copy_if_exists picker.sh ~/.config/themes/tools/
copy_if_exists style.css ~/.config/waybar/
copy_if_exists screenshot.sh ~/.config/dash/
copy_if_exists config ~/.config/waybar/
copy_if_exists sync.sh ~/.config/themes/tools/

# Make scripts executable
chmod 755 ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true

# ----------------------------------------------------------------------
# WAYBAR CONFIGURATION SELECTION
# ----------------------------------------------------------------------
echo ""
echo "Select Waybar configuration:"
echo "1) Laptop (with battery monitoring)"
echo "2) Desktop PC (with CPU/RAM monitoring)"
echo "3) Skip Waybar setup"
echo -n "Enter choice [1-3]: "
read waybar_choice

if [ "$waybar_choice" = "1" ] || [ "$waybar_choice" = "2" ]; then
    # ------------------------------------------------------------------
    # DEPLOY WAYBAR STYLE.CSS
    # ------------------------------------------------------------------
    echo "Deploying Waybar style.css..."
    safe_write ~/.config/waybar/style.css "$(cat << 'EOF'
@import "colors.css";

* {
    font-family: "JetBrains Mono", monospace;
    font-size: 15px;
    border-radius: 0;
    border: none;
}

window#waybar {
    background-color: @bg;
    color: @fg;
    border-bottom: 2px solid @fg;
}

#custom-launcher {
    padding: 0 15px;
    color: @fg;
    font-size: 20px;
}

#workspaces button {
    color: @fg;
    padding: 0 5px;
}

#workspaces button.active {
    background-color: @fg;
    color: @bg;
}

#workspaces button:hover {
    background-color: @fg;
    transition: all 0;
    color: @bg;
}

#custom-launcher:hover {
    background-color: @fg;
    color: @bg;
}

#network, #cpu, #memory, #backlight, #bluetooth, #wireplumber, #battery, #language {
    padding: 0 10px;
    color: @fg;
}
EOF
)"

    # ------------------------------------------------------------------
    # DEPLOY WAYBAR CONFIG (with correct language module)
    # ------------------------------------------------------------------
    if [ "$waybar_choice" = "1" ]; then
        # Laptop
        if [ "$layouts_count" -gt 1 ]; then
            echo "Configuring Waybar for Laptop (multilingual)..."
            safe_write ~/.config/waybar/config "$(cat << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock", "hyprland/language"],
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
)"
        else
            echo "Configuring Waybar for Laptop (monolingual)..."
            safe_write ~/.config/waybar/config "$(cat << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
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
)"
        fi
    else
        # Desktop PC
        if [ "$layouts_count" -gt 1 ]; then
            echo "Configuring Waybar for Desktop PC (multilingual)..."
            safe_write ~/.config/waybar/config "$(cat << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock", "hyprland/language"],
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
)"
        else
            echo "Configuring Waybar for Desktop PC (monolingual)..."
            safe_write ~/.config/waybar/config "$(cat << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
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
)"
        fi
    fi

    # Restart Waybar if running
    if pgrep -x "waybar" > /dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null || true
    fi
else
    echo "Skipping Waybar configuration..."
fi

# ----------------------------------------------------------------------
# CLEANUP
# ----------------------------------------------------------------------
cd /
rm -rf "$WORKSPACE"

echo ""
echo "===================================================="
echo "Installation complete!"
echo ""
echo "Configuration summary:"
if [ "$hypr_choice" = "1" ]; then
    echo "- Keyboard layout(s): $kb_layout"
    if [ "$kb_choice" = "2" ]; then
        echo "- Layout switching: Alt+Shift"
    fi
else
    echo "- Hyprland config: skipped (existing file kept)"
fi
if [ "$waybar_choice" = "1" ] || [ "$waybar_choice" = "2" ]; then
    echo "- Waybar: $([ "$waybar_choice" = "1" ] && echo "Laptop" || echo "Desktop PC")"
    echo "- Language module: $([ "$layouts_count" -gt 1 ] && echo "Enabled" || echo "Disabled")"
fi
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
echo "===================================================="
