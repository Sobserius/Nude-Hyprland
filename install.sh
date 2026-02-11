#!/bin/bash
set -e

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

echo "Creating folders..."
mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar

# ----------------------------------------------------------------------
# KEYBOARD LAYOUT CONFIGURATION
# ----------------------------------------------------------------------
echo ""
echo "Keyboard Layout Configuration"
echo "1) Single layout (monolingual)"
echo "2) Multiple layouts (bilingual / multilingual)"
echo -n "Enter choice [1-2]: "
read kb_choice

if [ "$kb_choice" = "1" ]; then
    echo -n "Enter your keyboard layout (default: us): "
    read kb_layout
    if [ -z "$kb_layout" ]; then
        kb_layout="us"
    fi
    kb_options=""
    layouts_count=1
else
    echo -n "Enter your keyboard layouts (comma-separated, e.g., us,ru,cz): "
    read kb_layout
    if [ -z "$kb_layout" ]; then
        kb_layout="us,ru"
    fi
    kb_options="grp:alt_shift_toggle"
    layouts_count=$(echo "$kb_layout" | tr ',' '\n' | wc -l)
fi

# ----------------------------------------------------------------------
# HYPRLAND.CONF GENERATION
# ----------------------------------------------------------------------
if [ -f "hyprland.conf" ]; then
    echo "Configuring Hyprland keyboard settings..."
    if [ "$kb_choice" = "1" ]; then
        sed -e "s/kb_layout = us,ru/kb_layout = $kb_layout/" \
            -e '/kb_options = grp:alt_shift_toggle/d' \
            hyprland.conf > ~/.config/hypr/hyprland.conf
    else
        sed "s/kb_layout = us,ru/kb_layout = $kb_layout/" \
            hyprland.conf | \
        sed "/kb_layout = $kb_layout/a\\
kb_options = $kb_options" \
            > ~/.config/hypr/hyprland.conf
    fi
else
    echo "Warning: hyprland.conf not found in repository"
fi

# ----------------------------------------------------------------------
# COPY BASE CONFIGURATION FILES
# ----------------------------------------------------------------------
echo "Copying files..."
cp colors.conf ~/.config/themes/ 2>/dev/null || true
cp dashboard.sh ~/.config/dash/ 2>/dev/null || true
cp hypridle.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock-colors.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock.conf ~/.config/hypr/ 2>/dev/null || true
cp launcher.sh ~/.config/dash/ 2>/dev/null || true
cp picker.sh ~/.config/themes/tools/ 2>/dev/null || true
cp screenshot.sh ~/.config/dash/ 2>/dev/null || true
cp sync.sh ~/.config/themes/tools/ 2>/dev/null || true

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

# ----------------------------------------------------------------------
# DEPLOY WAYBAR CONFIG AND STYLE.CSS
# ----------------------------------------------------------------------
if [ "$waybar_choice" = "1" ] || [ "$waybar_choice" = "2" ]; then
    # Always deploy the style.css
    echo "Deploying Waybar style.css..."
    cat > ~/.config/waybar/style.css << 'EOF'
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

    # Deploy Waybar config based on device and language count
    if [ "$waybar_choice" = "1" ]; then
        # Laptop config
        if [ "$layouts_count" -gt 1 ]; then
            echo "Configuring Waybar for Laptop (multilingual)..."
            cat > ~/.config/waybar/config << 'EOF'
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
        else
            echo "Configuring Waybar for Laptop (monolingual)..."
            cat > ~/.config/waybar/config << 'EOF'
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
        fi
    else
        # Desktop PC config
        if [ "$layouts_count" -gt 1 ]; then
            echo "Configuring Waybar for Desktop PC (multilingual)..."
            cat > ~/.config/waybar/config << 'EOF'
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
        else
            echo "Configuring Waybar for Desktop PC (monolingual)..."
            cat > ~/.config/waybar/config << 'EOF'
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
        fi
    fi
else
    echo "Skipping Waybar configuration..."
fi

# ----------------------------------------------------------------------
# FINAL TOUCHES
# ----------------------------------------------------------------------
chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true

# Restart Waybar if it's running
if pgrep -x "waybar" > /dev/null && [ "$waybar_choice" != "3" ]; then
    killall -SIGUSR2 waybar 2>/dev/null || true
fi

# Cleanup
cd /
rm -rf "$WORKSPACE"

echo ""
echo "===================================================="
echo "Installation complete!"
echo ""
echo "Configuration summary:"
echo "- Keyboard layout(s): $kb_layout"
if [ "$kb_choice" = "2" ]; then
    echo "- Layout switching: Alt+Shift"
fi
if [ "$waybar_choice" = "1" ] || [ "$waybar_choice" = "2" ]; then
    echo "- Waybar: $([ "$waybar_choice" = "1" ] && echo "Laptop" || echo "Desktop PC")"
    echo "- Language module: $([ "$layouts_count" -gt 1 ] && echo "Enabled" || echo "Disabled")"
fi
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
echo "===================================================="b 
