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
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Main installation process
main() {
    echo "This script will:"
    echo "1. Download config files from the Pastel-Integrated branch"
    echo "2. Copy them to ~/.config/"
    echo "3. Make scripts executable"
    echo
    warn "Note: This does NOT install system packages (hyprland, kitty, etc.)."
    echo
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi
    
    # Create a temporary directory and clone the repo there
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    info "Downloading files from GitHub..."
    if ! git clone --depth 1 --branch Pastel-Integrated \
        https://github.com/Sobserius/Nude-Hyprland.git . > /dev/null 2>&1; then
        error "Failed to download files. Check your internet or the branch name."
        exit 1
    fi
    
    # Verify we got the files
    if [ ! -f "hyprland.conf" ] || [ ! -f "colors.conf" ]; then
        warn "Warning: Some expected files are missing from the branch."
        echo "Files in current directory:"
        ls -la
    fi
    
    # Backup existing configs if they exist
    if [ -d ~/.config/hypr ] || [ -d ~/.config/waybar ]; then
        warn "Existing configs detected!"
        read -p "Backup to ~/.config-backup? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            for dir in hypr waybar dunst themes dash; do
                if [ -d ~/.config/$dir ]; then
                    cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null && \
                    echo "  Backed up ~/.config/$dir"
                fi
            done
            info "Backup created at $BACKUP_DIR"
        fi
    fi
    
    # Create target directories
    info "Creating config directories..."
    mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar
    
    # Copy files - ALL SOURCE FILES ARE IN CURRENT DIRECTORY (TEMP_DIR)
    info "Copying configuration files..."
    
    # Files to copy mapping: source_file -> destination
    # Since all files are in the root of the repo, we just list them
    declare -A files_to_copy=(
        # Format: ["source_filename"]="destination_path"
        ["colors.conf"]="~/.config/themes/"
        ["dashboard.sh"]="~/.config/dash/"
        ["hypridle.conf"]="~/.config/hypr/"
        ["hyprland.conf"]="~/.config/hypr/"
        ["hyprlock-colors.conf"]="~/.config/hypr/"
        ["hyprlock.conf"]="~/.config/hypr/"
        ["launcher.sh"]="~/.config/dash/"
        ["picker.sh"]="~/.config/themes/tools/"
        ["style.css"]="~/.config/waybar/"
        ["screenshot.sh"]="~/.config/dash/"
        ["config"]="~/.config/waybar/"
        ["sync.sh"]="~/.config/themes/tools/"
    )
    
    # Actually copy each file
    for source_file in "${!files_to_copy[@]}"; do
        dest="${files_to_copy[$source_file]}"
        
        if [ -f "$source_file" ]; then
            # Expand ~ to actual home path
            eval expanded_dest="$dest"
            cp "$source_file" "$expanded_dest"
            info "  Copied: $source_file -> $dest"
        else
            warn "  Missing: $source_file (not found in repository)"
        fi
    done
    
    # Make scripts executable
    info "Making scripts executable..."
    chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null || true
    
    # Clean up
    cd /
    rm -rf "$TEMP_DIR"
    
    # Final message
    echo
    echo "================================================"
    info "File setup complete!"
    echo
    echo "Required packages (install manually):"
    echo "  Arch:   sudo pacman -S hyprland kitty dunst waybar ..."
    echo "  Fedora: sudo dnf install hyprland kitty dunst waybar ..."
    echo
    echo "Start Hyprland from your display manager or TTY."
    echo "================================================"
}

# Run the installation
main "$@"
