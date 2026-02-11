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

# Language selection
echo ""
echo "Language Configuration:"
echo "1) Monolingual (US keyboard only)"
echo "2) Bilingual (US + Russian keyboards)"
echo -n "Enter choice [1-2]: "
read lang_choice

# Copy and modify hyprland.conf based on language choice
if [ -f "hyprland.conf" ]; then
    if [ "$lang_choice" = "1" ]; then
        echo "Configuring monolingual setup..."
        # For monolingual: keep only us layout, remove kb_options
        sed -e 's/kb_layout = us,ru/kb_layout = us/' \
            -e '/kb_options = grp:alt_shift_toggle/d' \
            hyprland.conf > ~/.config/hypr/hyprland.conf
    else
        echo "Configuring bilingual setup..."
        # For bilingual: keep original settings
        cp hyprland.conf ~/.config/hypr/hyprland.conf
    fi
else
    echo "Warning: hyprland.conf not found in repository"
fi

# Copy other configuration files
echo "Copying files..."
cp colors.conf ~/.config/themes/ 2>/dev/null || true
cp dashboard.sh ~/.config/dash/ 2>/dev/null || true
cp hypridle.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock-colors.conf ~/.config/hypr/ 2>/dev/null || true
cp hyprlock.conf ~/.config/hypr/ 2>/dev/null || true
cp launcher.sh ~/.config/dash/ 2>/dev/null || true
cp picker.sh ~/.config/themes/tools/ 2>/dev/null || true
cp style.css ~/.config/waybar/ 2>/dev/null || true
cp screenshot.sh ~/.config/dash/ 2>/dev/null || true
cp sync.sh ~/.config/themes/tools/ 2>/dev/null || true

# Waybar configuration selection
echo ""
echo "Select Waybar configuration:"
echo "1) Laptop (with battery monitoring)"
echo "2) Desktop PC (with CPU/RAM monitoring)"
echo "3) Skip Waybar setup"
echo -n "Enter choice [1-3]: "
read waybar_choice

# Function to create Waybar config based on language choice
create_waybar_config() {
    local is_bilingual=$1
    local config_type=$2
    
    if [ "$config_type" = "laptop" ]; then
        cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": [ "clock"EOF
        
        if [ "$is_bilingual" = "yes" ]; then
            echo '    , "hyprland/language"' >> ~/.config/waybar/config
        fi
        
        cat >> ~/.config/waybar/config << 'EOF'
    ],
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
EOF
        
        if [ "$is_bilingual" = "yes" ]; then
            cat >> ~/.config/waybar/config << 'EOF'

    "hyprland/language": {
        "format": "{}"
    },
EOF
        fi
        
        cat >> ~/.config/waybar/config << 'EOF'
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
        # Desktop PC configuration
        cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "bottom",
    "reload_style_on_change": true,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": [ "clock"EOF
        
        if [ "$is_bilingual" = "yes" ]; then
            echo '    , "hyprland/language"' >> ~/.config/waybar/config
        fi
        
        cat >> ~/.config/waybar/config << 'EOF'
    ],
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
EOF
        
        if [ "$is_bilingual" = "yes" ]; then
            cat >> ~/.config/waybar/config << 'EOF'

    "hyprland/language": {
        "format": "{}"
    },
EOF
        fi
        
        cat >> ~/.config/waybar/config << 'EOF'
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
}

# Create Waybar config based on choices
if [ "$waybar_choice" = "1" ]; then
    echo "Configuring Waybar for Laptop..."
    if [ "$lang_choice" = "2" ]; then
        create_waybar_config "yes" "laptop"
    else
        create_waybar_config "no" "laptop"
    fi
elif [ "$waybar_choice" = "2" ]; then
    echo "Configuring Waybar for Desktop PC..."
    if [ "$lang_choice" = "2" ]; then
        create_waybar_config "yes" "desktop"
    else
        create_waybar_config "no" "desktop"
    fi
else
    echo "Skipping Waybar configuration..."
fi

# Make scripts executable
chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true

# Cleanup
cd /
rm -rf "$WORKSPACE"

# Restart Waybar if it's running
if pgrep -x "waybar" > /dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || true
fi

echo ""
echo "===================================================="
echo "Installation complete!"
echo ""
echo "Configuration summary:"
echo "- Keyboard layout: $([ "$lang_choice" = "1" ] && echo "Monolingual (US)" || echo "Bilingual (US+RU)")"
if [ "$waybar_choice" = "1" ] || [ "$waybar_choice" = "2" ]; then
    echo "- Waybar: $([ "$waybar_choice" = "1" ] && echo "Laptop" || echo "Desktop PC")"
    echo "- Language module: $([ "$lang_choice" = "2" ] && echo "Enabled" || echo "Disabled")"
fi
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
echo "===================================================="
