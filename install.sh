#!/usr/bin/env bash
set -euo pipefail

# Hyprland Configuration Install Script
# For Arch Linux and Arch-based distributions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
BACKUP_DIR="$HOME/.config-backup/hyprland-$(date +%Y%m%d-%H%M%S)"
CONFIG_DIRS=(
    "hypr"
    "waybar"
    "kitty"
    "rofi"
    "wofi"
    "yazi"
    "neofetch"
    "autostart"
    "qalculate"
)

# Print functions
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Hyprland Configuration Installer for Arch Linux        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Check if running on Arch Linux
check_distro() {
    if [[ ! -f /etc/arch-release ]]; then
        print_warning "This script is designed for Arch Linux"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check for required commands
check_dependencies() {
    print_info "Checking for required dependencies..."

    local missing_deps=()

    # Check for pacman
    if ! command -v pacman &> /dev/null; then
        print_error "pacman not found. Are you running Arch Linux?"
        exit 1
    fi

    # Check for git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        read -p "Install missing dependencies? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed "${missing_deps[@]}"
        else
            print_error "Cannot proceed without required dependencies"
            exit 1
        fi
    fi

    print_success "All required dependencies are installed"
}

# Backup existing configurations
backup_configs() {
    print_info "Backing up existing configurations..."

    local needs_backup=false

    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$HOME/.config/$dir" ]]; then
            needs_backup=true
            break
        fi
    done

    if [[ "$needs_backup" == true ]]; then
        mkdir -p "$BACKUP_DIR"

        for dir in "${CONFIG_DIRS[@]}"; do
            if [[ -d "$HOME/.config/$dir" ]]; then
                print_info "Backing up ~/.config/$dir"
                cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
            fi
        done

        print_success "Configurations backed up to $BACKUP_DIR"
    else
        print_info "No existing configurations found to backup"
    fi
}

# Install Hyprland packages
install_packages() {
    print_info "Installing Hyprland and related packages..."

    local core_packages=(
        # Hyprland core
        "hyprland"
        "hyprpaper"
        "hyprlock"
        "hyprshot"
        "xdg-desktop-portal-hyprland"

        # Wayland essentials
        "wayland"
        "wayland-protocols"

        # GUI components
        "waybar"
        "rofi"
        "wofi"
        "dunst"
        "kitty"

        # Audio
        "pipewire"
        "pipewire-pulse"
        "pipewire-jack"
        "wireplumber"

        # System utilities
        "brightnessctl"
        "playerctl"
        "wl-clipboard"
        "cliphist"
        "network-manager-applet"
        "blueman"
        "udiskie"
        "polkit-gnome"
        "gnome-keyring"

        # File management
        "yazi"
        "ffmpegthumbnailer"
        "p7zip"
        "jq"
        "poppler"
        "fd"
        "ripgrep"
        "fzf"
        "imagemagick"
    )

    print_info "Checking which packages need to be installed..."

    local to_install=()
    for pkg in "${core_packages[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        print_info "Packages to install: ${to_install[*]}"
        read -p "Install these packages? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed "${to_install[@]}"
            print_success "Core packages installed"
        else
            print_warning "Skipping package installation"
        fi
    else
        print_success "All core packages are already installed"
    fi
}

# Install AUR packages
install_aur_packages() {
    print_info "Optional AUR packages..."

    # Check for AUR helper
    local aur_helper=""
    if command -v yay &> /dev/null; then
        aur_helper="yay"
    elif command -v paru &> /dev/null; then
        aur_helper="paru"
    else
        print_warning "No AUR helper found (yay or paru)"
        print_info "You can manually install AUR packages later:"
        print_info "  - brave-bin (browser)"
        print_info "  - sublime-text-4 (editor)"
        print_info "  - obsidian (notes)"
        print_info "  - localsend-bin (file sharing)"
        return
    fi

    local aur_packages=("brave-bin" "sublime-text-4" "obsidian" "localsend-bin")

    print_info "Optional AUR packages: ${aur_packages[*]}"
    read -p "Install AUR packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $aur_helper -S --needed "${aur_packages[@]}"
        print_success "AUR packages installed"
    else
        print_info "Skipping AUR packages"
    fi
}

# Deploy configuration files
deploy_configs() {
    print_info "Deploying configuration files..."

    # Copy config directory
    if [[ -d "$SCRIPT_DIR/config" ]]; then
        print_info "Copying configurations to ~/.config/"
        mkdir -p "$HOME/.config"

        for dir in "${CONFIG_DIRS[@]}"; do
            if [[ -d "$SCRIPT_DIR/config/$dir" ]]; then
                print_info "Installing $dir configuration"
                cp -r "$SCRIPT_DIR/config/$dir" "$HOME/.config/"
            fi
        done

        print_success "Configuration files deployed"
    else
        print_error "Config directory not found: $SCRIPT_DIR/config"
        exit 1
    fi

    # Copy local directory
    if [[ -d "$SCRIPT_DIR/local" ]]; then
        print_info "Copying local files to ~/.local/"
        mkdir -p "$HOME/.local/bin"
        cp -r "$SCRIPT_DIR/local/"* "$HOME/.local/"
        print_success "Local files deployed"
    fi
}

# Set executable permissions
set_permissions() {
    print_info "Setting executable permissions for scripts..."

    # Hypr scripts
    if [[ -d "$HOME/.config/hypr/Scripts" ]]; then
        chmod +x "$HOME/.config/hypr/Scripts/"*.sh
        print_success "Hyprland scripts are now executable"
    fi

    # Yazi scripts
    if [[ -d "$HOME/.config/yazi/Scripts" ]]; then
        chmod +x "$HOME/.config/yazi/Scripts/"*.sh
        print_success "Yazi scripts are now executable"
    fi

    # Local bin
    if [[ -d "$HOME/.local/bin" ]]; then
        chmod +x "$HOME/.local/bin/"*
        print_success "Local binaries are now executable"
    fi
}

# Configure user-specific settings
configure_user_settings() {
    print_info "Configuring user-specific settings..."

    # Update monitor configuration for user's system
    print_warning "You may need to adjust monitor configuration for your system"
    print_info "Edit: ~/.config/hypr/UserConfigs/04-monitors.conf"
    print_info "Run 'hyprctl monitors' to see your monitor names"

    # Note about applications
    print_warning "Review autostart applications in:"
    print_info "  ~/.config/hypr/UserConfigs/05-autostart.conf"
    print_info "  ~/.config/autostart/"
}

# Install Hyprland plugins
install_plugins() {
    print_info "Installing Hyprland plugins..."

    read -p "Install Hyprland plugins (hyprexpo, hyprfocus)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v hyprpm &> /dev/null; then
            hyprpm add https://github.com/hyprwm/hyprland-plugins
            hyprpm enable hyprexpo
            hyprpm enable hyprfocus
            hyprpm reload -n
            print_success "Hyprland plugins installed"
        else
            print_error "hyprpm not found. Install Hyprland first."
        fi
    else
        print_info "Skipping plugin installation"
    fi
}

# Enable user services
enable_services() {
    print_info "Enabling user services..."

    # Enable PipeWire
    if systemctl --user list-unit-files | grep -q pipewire.service; then
        systemctl --user enable --now pipewire.service pipewire-pulse.service
        print_success "PipeWire services enabled"
    fi
}

# Post-installation instructions
print_post_install() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  Installation Complete!                                  ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_success "Hyprland configuration has been installed"
    echo ""
    print_info "Next steps:"
    echo "  1. Log out of your current session"
    echo "  2. Select 'Hyprland' from your display manager"
    echo "  3. Log in and enjoy your new desktop!"
    echo ""
    print_info "Important keybindings:"
    echo "  SUPER + /          - Show keybind help"
    echo "  SUPER + T          - Open terminal"
    echo "  SUPER + Space      - Application menu"
    echo "  SUPER + Q          - Close window"
    echo "  SUPER + M          - Exit Hyprland"
    echo ""
    print_info "Configuration files:"
    echo "  Main config:       ~/.config/hypr/hyprland.conf"
    echo "  Keybindings:       ~/.config/hypr/UserConfigs/03-keybinds.conf"
    echo "  Monitors:          ~/.config/hypr/UserConfigs/04-monitors.conf"
    echo "  Autostart:         ~/.config/hypr/UserConfigs/05-autostart.conf"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        print_info "Your old configurations are backed up at:"
        echo "  $BACKUP_DIR"
        echo ""
    fi
    print_info "For more information, see README.md"
    echo ""
}

# Main installation flow
main() {
    print_header

    # Prompt for confirmation
    print_info "This script will install Hyprland and its configuration"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    check_distro
    check_dependencies
    backup_configs
    install_packages
    install_aur_packages
    deploy_configs
    set_permissions
    configure_user_settings
    install_plugins
    enable_services
    print_post_install
}

# Run main function
main "$@"
