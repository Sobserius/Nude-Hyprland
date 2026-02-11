#!/bin/bash
set -e

echo "================================================"
echo " Nude-Hyprland Install"
echo "================================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}>>>${NC} $1"; }

# Function to clean up temporary directory
cleanup() {
    if [ -d "$TEMP_DIR" ] && [[ "$TEMP_DIR" =~ /tmp/nude-hyprland- ]]; then
        rm -rf "$TEMP_DIR"
        info "Cleaned up temporary files."
    fi
}

# Set trap to clean up on exit
trap cleanup EXIT

# Create a temporary directory
TEMP_DIR=$(mktemp -d /tmp/nude-hyprland-XXXXXX)
cd "$TEMP_DIR"

# Main installation process
main() {
    echo
    echo "This script will:"
    echo "1. Download the Nude-Hyprland configuration files"
    echo "2. Copy them to ~/.config/"
    echo "3. Make all scripts executable"
    echo
    warn "Note: This script does NOT install system dependencies."
    echo
    
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi
    
    # Clone the repository
    step "Downloading configuration files..."
    if git clone --depth 1 --branch Pastel-Integrated \
        https://github.com/Sobserius/Nude-Hyprland.git . 2>/dev/null; then
        info "Successfully downloaded files!"
    else
        error "Failed to download files. Please check your internet connection."
        exit 1
    fi
    
    # Check if we have the files we need
    if [ ! -f "hyprland.conf" ] || [ ! -f "install.sh" ]; then
        warn "Repository structure may have changed. Checking for config files..."
    fi
    
    # Backup existing configs (optional)
    if [ -d ~/.config/hypr ] || [ -d ~/.config/waybar ]; then
        warn "Existing configuration files detected!"
        read -p "Backup existing configs to ~/.config-backup? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            for dir in hypr waybar dunst themes dash; do
                if [ -d ~/.config/$dir ]; then
                    cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null
                fi
            done
            info "Backup created at $BACKUP_DIR"
        fi
    fi
    
    # Create directories and copy files
    step "Setting up configuration directories..."
    mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar
    
    # List of files to copy (adjust based on your actual repo structure)
    declare -A files_to_copy=(
        ["colors.conf"]="~/.config/themes/"
        ["dashboard.sh"]="~/.config/dash/"
        ["hypridle.conf"]="~/.config/hypr/"
        ["hyprland.conf"]="~/.config/hypr/"
        ["hyprlock-colors.conf"]="~/.config/hypr/hyprlock-colors.conf"
        ["hyprlock.conf"]="~/.config/hypr/hyprlock.conf"
        ["launcher.sh"]="~/.config/dash/"
        ["picker.sh"]="~/.config/themes/tools/"
        ["style.css"]="~/.config/waybar/"
        ["screenshot.sh"]="~/.config/dash/"
        ["config"]="~/.config/waybar/"
        ["sync.sh"]="~/.config/themes/tools/"
    )
    
    step "Copying configuration files..."
    files_copied=0
    files_missing=0
    
    for file in "${!files_to_copy[@]}"; do
        dest="${files_to_copy[$file]}"
        if [ -f "$file" ]; then
            eval dest_expanded="$dest"
            cp -v "$file" "$dest_expanded"
            ((files_copied++))
        else
            warn "Note: '$file' not found in repository (might be in a subdirectory)"
            ((files_missing++))
        fi
    done
    
    # Make scripts executable
    step "Making scripts executable..."
    chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true
    
    # Final verification and message
    echo
    echo "================================================"
    if [ $files_copied -gt 0 ]; then
        info "Successfully copied $files_copied files!"
        if [ $files_missing -gt 0 ]; then
            warn "$files_missing files were not found. Check your repository structure."
        fi
    else
        error "No files were copied! Please check the repository structure."
        exit 1
    fi
    
    echo
    echo "Important: This script only copies configuration files."
    echo "You must manually install required packages such as:"
    echo "  hyprland, kitty, dunst, waybar, swww, grim, slurp, etc."
    echo
    echo "For Arch Linux:"
    echo "  sudo pacman -S hyprland kitty dunst waybar fzf jq inotify-tools \\"
    echo "    imagemagick swww grim slurp hyprpicker hyprlock wl-clipboard \\"
    echo "    playerctl brightnessctl j4-dmenu-desktop adw-gtk-theme chafa pastel"
    echo
    echo "For Fedora:"
    echo "  sudo dnf install hyprland kitty dunst waybar fzf jq inotify-tools \\"
    echo "    ImageMagick swww grim slurp hyprpicker hyprlock wl-clipboard \\"
    echo "    playerctl brightnessctl j4-dmenu-desktop adw-gtk3-theme chafa pastel"
    echo
    echo "Next steps:"
    echo "1. Install required packages for your distribution"
    echo "2. Log out and select Hyprland from your display manager"
    echo "3. Or start Hyprland directly from TTY: Hyprland"
    echo "================================================"
}

# Run main function
main "$@"
