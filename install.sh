#!/bin/bash
set -e

echo "================================================"
echo " Nude-Hyprland Setup"
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

# Check if running as normal user (not root)
if [ "$EUID" -eq 0 ]; then
    error "Please run as normal user, not as root/sudo."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Function to copy configuration files
copy_config_files() {
    info "Setting up configuration directories..."
    
    # Create all necessary directories
    mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar
    
    # Copy files with verification
    info "Copying configuration files..."
    
    # List of files to copy with their destinations
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
    
    # Copy each file
    for file in "${!files_to_copy[@]}"; do
        dest="${files_to_copy[$file]}"
        
        # Check if source file exists
        if [ -f "$file" ]; then
            # Expand the ~ in destination path
            eval dest_expanded="$dest"
            cp -v "$file" "$dest_expanded"
        else
            warn "Source file not found: $file"
        fi
    done
    
    # Make scripts executable
    info "Making scripts executable..."
    chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 2>/dev/null
    
    # Verify the copies
    info "Verifying installation..."
    if [ -f ~/.config/hypr/hyprland.conf ] && [ -f ~/.config/waybar/config ]; then
        info "Core configuration files installed successfully!"
    else
        warn "Some configuration files might be missing."
    fi
}

# Function to backup existing configs
backup_existing() {
    if [ -d ~/.config/hypr ] || [ -d ~/.config/waybar ] || [ -d ~/.config/dunst ]; then
        warn "Existing configuration files detected!"
        
        read -p "Backup existing configs to ~/.config-backup? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
            info "Creating backup at $BACKUP_DIR"
            
            mkdir -p "$BACKUP_DIR"
            
            # Backup directories if they exist
            for dir in hypr waybar dunst themes dash; do
                if [ -d ~/.config/$dir ]; then
                    cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null && \
                    info "  Backed up ~/.config/$dir"
                fi
            done
        fi
    fi
}

# Main installation process
main() {
    echo
    echo "This script will:"
    echo "1. Copy configuration files to ~/.config"
    echo "2. Make all scripts executable"
    echo
    warn "Note: This script does NOT install system dependencies."
    warn "Make sure required packages are installed before using these configs."
    echo
    
    read -p "Continue with file installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi
    
    # Backup existing configs
    backup_existing
    
    # Copy configuration files
    copy_config_files
    
    # Final message
    echo
    echo "================================================"
    info "File setup complete!"
    echo
    echo "Important: This script only copies configuration files."
    echo "You must manually install required packages such as:"
    echo "  hyprland, kitty, dunst, waybar, swww, grim, slurp, etc."
    echo
    echo "Next steps:"
    echo "1. Install required packages for your distribution"
    echo "2. Log out and select Hyprland from your display manager"
    echo "3. Or start Hyprland directly from TTY: Hyprland"
    echo "================================================"
}

# Run main function
main "$@"
