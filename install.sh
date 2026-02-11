#!/bin/bash
set -e
clear && sleep 0.5
read -p "Continue? (y/N): " -n 1 -r
clear ** sleep 0.5
echo "===================================================="
echo "Nude-Hyprland Installation"
echo "===================================================="

#!/bin/bash
set -e

WORKSPACE=$(mktemp -d)
cd "$WORKSPACE"

git clone --quiet --depth 1 --branch Pastel-Integrated \
    https://github.com/Sobserius/Nude-Hyprland.git source_files

cd source_files

mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar

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

chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true

cd /
rm -rf "$WORKSPACE"
echo "File deployment is complete."
echo ""
echo "Note: System dependencies are not installed by this script."
echo "A system reboot is recommended before starting Hyprland."
