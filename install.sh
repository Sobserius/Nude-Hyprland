#!/bin/bash
set -e

echo "Nude-Hyprland Installation"
echo "===================================================="

WORKSPACE=$(mktemp -d)
cd "$WORKSPACE"
git clone --quiet --depth 1 --branch Pastel-Integrated \
    https://github.com/Sobserius/Nude-Hyprland.git .

echo "Repository cloned to temporary workspace."

if [ ! -f "hyprland.conf" ] || [ ! -f "colors.conf" ]; then
    echo "Error: Required configuration files not found in repository root."
    exit 1
fi

mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar

echo "Deploying configuration files..."
cp colors.conf ~/.config/themes/
cp dashboard.sh ~/.config/dash/
cp hypridle.conf ~/.config/hypr/
cp hyprland.conf ~/.config/hypr/
cp hyprlock-colors.conf ~/.config/hypr/
cp hyprlock.conf ~/.config/hypr/
cp launcher.sh ~/.config/dash/
cp picker.sh ~/.config/themes/tools/
cp style.css ~/.config/waybar/
cp screenshot.sh ~/.config/dash/
cp config ~/.config/waybar/
cp sync.sh ~/.config/themes/tools/

echo "Setting script permissions..."
chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh

# Cleanup the temporary workspace.
cd /
rm -rf "$WORKSPACE"

echo "File deployment is complete."
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
