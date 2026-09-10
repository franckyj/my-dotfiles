#!/usr/bin/env bash
#
# Fedora 44 + Hyprland + Noctalia v5 post-install setup
#
# Based on:
# https://codeberg.org/justaguylinux/oxwm-setup/src/branch/main/install.sh
#

set -euo pipefail


# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

readonly FEDORA_VERSION="44"
readonly DOTFILES_DIR="$HOME/dev/github/franckyj/my-dotfiles"
readonly LOG_FILE="$HOME/fedora-install.log"


# ─────────────────────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'


# ─────────────────────────────────────────────────────────────────────────────
# Output helpers
# ─────────────────────────────────────────────────────────────────────────────

die() {
    echo -e "${RED}ERROR: $*${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}WARNING: $*${NC}" >&2
}

msg() {
    echo -e "${CYAN}$*${NC}"
}

success() {
    echo -e "${GREEN}$*${NC}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Generic installation helpers
# ─────────────────────────────────────────────────────────────────────────────

install_packages() {
    sudo dnf install -y "$@"
}

install_flatpak() {
    flatpak install -y flathub "$1"
}

enable_coprs() {
    local coprs=("$@")

    for copr in "${coprs[@]}"; do
        sudo dnf copr enable -y "$copr"
    done
}


# ─────────────────────────────────────────────────────────────────────────────
# Environment
# ─────────────────────────────────────────────────────────────────────────────

check_environment() {
    msg "checking environment"

    if [[ $EUID -eq 0 ]]; then
        die "Do not run this script as root."
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        die "sudo is required."
    fi

    if [[ ! -f /etc/fedora-release ]]; then
        die "This script is intended for Fedora."
    fi

    local detected_version
    detected_version="$(rpm -E %fedora)"

    if [[ "$detected_version" != "$FEDORA_VERSION" ]]; then
        warn "This script was written for Fedora ${FEDORA_VERSION}, but Fedora ${detected_version} was detected."
    fi

    sudo -v
}


# ─────────────────────────────────────────────────────────────────────────────
# DNF
# ─────────────────────────────────────────────────────────────────────────────

configure_dnf() {
    msg "configuring DNF"

    local dnf_conf="/etc/dnf/dnf.conf"

    local settings=(
        "max_parallel_downloads=10"    # Download multiple packages in parallel
        "fastestmirror=True"            # Prefer faster mirrors
        "keepcache=True"                # Keep downloaded packages in the cache
    )

    for setting in "${settings[@]}"; do
        local key="${setting%%=*}"

        if ! grep -q "^${key}=" "$dnf_conf"; then
            echo "$setting" | sudo tee -a "$dnf_conf" >/dev/null
        fi
    done
}


update_system() {
    msg "updating system"

    sudo dnf upgrade --refresh -y

    local packages=(
        dnf-plugins-core                # DNF plugins such as COPR and repository management
    )

    install_packages "${packages[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Firmware
# ─────────────────────────────────────────────────────────────────────────────

update_firmware() {
    msg "checking firmware updates"

    sudo fwupdmgr refresh
    sudo fwupdmgr get-devices
    sudo fwupdmgr get-updates

    warn "firmware will not be updated automatically."
    warn "run 'sudo fwupdmgr update' after reboot if updates are available."
}


# ─────────────────────────────────────────────────────────────────────────────
# RPM Fusion
# ─────────────────────────────────────────────────────────────────────────────

enable_rpmfusion() {
    msg "enabling RPM Fusion"

    local repositories=(
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"     # RPM Fusion Free repository
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" # RPM Fusion Nonfree repository
    )

    install_packages "${repositories[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Hyprland / Wayland
# ─────────────────────────────────────────────────────────────────────────────

enable_hyprland_copr() {
    msg "enabling Hyprland COPR"

    local coprs=(
        lionheartp/Hyprland             # Hyprland COPR repository
    )

    enable_coprs "${coprs[@]}"
}


install_hyprland() {
    msg "installing Hyprland and Wayland utilities"

    local packages=(
        hyprland                        # Wayland compositor
        hypridle                         # Idle daemon for Hyprland
        hyprpolkitagent                  # Polkit authentication agent
        xdg-desktop-portal               # Desktop integration portal framework
        xdg-desktop-portal-hyprland      # Hyprland XDG portal backend
        xdg-desktop-portal-gtk           # GTK XDG portal backend
        wl-clipboard                     # Wayland clipboard utilities
        brightnessctl                     # Display/backlight brightness control
        pipewire                          # Audio/video multimedia server
        wireplumber                       # PipeWire session/policy manager
        playerctl                         # MPRIS media player controller
        pavucontrol                       # GUI audio mixer
        qt5-wayland                       # Qt 5 Wayland platform support
        qt6-wayland                       # Qt 6 Wayland platform support
    )

    install_packages "${packages[@]}"

    # No hyprpaper:
    # Noctalia provides wallpaper management.
}


# ─────────────────────────────────────────────────────────────────────────────
# Multimedia
# ─────────────────────────────────────────────────────────────────────────────

install_multimedia() {
    msg "installing multimedia support"

    local packages=(
        ffmpeg                           # Audio/video encoding and decoding
        ffmpeg-libs                      # FFmpeg runtime libraries
        libva                             # Video Acceleration API
        libva-utils                        # VA-API diagnostic utilities
        libfreeaptx                        # aptX Bluetooth audio codec
        libldac                            # LDAC Bluetooth audio codec
        fdk-aac                            # AAC audio encoder
    )

    install_packages "${packages[@]}"

    sudo dnf4 group install -y multimedia

    sudo dnf update @multimedia \
        --setopt="install_weak_deps=False" \
        --exclude=PackageKit-gstreamer-plugin

    sudo dnf group install -y sound-and-video

    sudo dnf swap ffmpeg-free ffmpeg --allowerasing
}


install_intel_media_driver() {
    if lspci | grep -qi 'Intel.*VGA\|Intel.*Display'; then
        msg "Intel graphics detected; installing Intel media driver"

        local packages=(
            intel-media-driver                # Intel hardware video acceleration driver
        )

        install_packages "${packages[@]}"

        sudo dnf swap \
            libva-intel-media-driver \
            intel-media-driver \
            --allowerasing
    else
        msg "Intel graphics not detected; skipping Intel media driver"
    fi
}


install_freeworld_drivers() {
    msg "installing Mesa Freeworld drivers"

    sudo dnf swap \
        mesa-va-drivers \
        mesa-va-drivers-freeworld \
        --allowerasing

    sudo dnf swap \
        mesa-vdpau-drivers \
        mesa-vdpau-drivers-freeworld \
        --allowerasing
}


# ─────────────────────────────────────────────────────────────────────────────
# Basic utilities
# ─────────────────────────────────────────────────────────────────────────────

install_basic_utilities() {
    msg "installing basic utilities"

    local packages=(
        git                               # Distributed version control
        curl                              # Transfer data from URLs
        wget                              # Download files from the web
        unzip                             # Extract ZIP archives
        p7zip                             # 7-Zip archive support
        p7zip-plugins                     # Additional 7-Zip archive formats
    )

    install_packages "${packages[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Shell
# ─────────────────────────────────────────────────────────────────────────────

install_shell() {
    msg "installing Zsh"

    local packages=(
        zsh                               # Z shell
    )

    install_packages "${packages[@]}"

    local zsh_path
    zsh_path="$(command -v zsh)"

    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
    fi
}


install_starship() {
    msg "installing Starship"

    curl -sS https://starship.rs/install.sh | sh
}


install_atuin() {
    msg "installing Atuin"

    curl \
        --proto '=https' \
        --tlsv1.2 \
        -LsSf https://setup.atuin.sh \
        | sh
}


# ─────────────────────────────────────────────────────────────────────────────
# Development tools
# ─────────────────────────────────────────────────────────────────────────────

install_development_tools() {
    msg "installing command-line development tools"

    local packages=(
        eza                               # Modern replacement for ls
        bat                               # cat with syntax highlighting and paging
        ripgrep                           # Fast replacement for grep
        fd-find                           # Fast replacement for find
        zoxide                            # Smarter replacement for cd
        fzf                               # Interactive fuzzy finder
        btop                              # Interactive resource monitor
        htop                              # Interactive process viewer
        iotop-c                           # Monitor disk I/O by process
        nvtop                             # GPU monitoring tool
        du-dust                           # Modern replacement for du
        duf                               # Modern replacement for df
        ncdu                              # Interactive disk usage analyzer
        fastfetch                         # System information display
        git-delta                         # Syntax-highlighted Git diff viewer
        jq                                # JSON command-line processor
        yq                                # YAML/JSON/XML command-line processor
        gh                                # GitHub CLI
        tldr                              # Simplified command-line documentation
        neovim                            # Vim-based text editor
        helix                             # Modal terminal text editor
        yazi                              # Terminal file manager
        mise                              # Development tool/version manager
        stow                              # Symlink manager for dotfiles
    )

    install_packages "${packages[@]}"
}


install_lazygit() {
    msg "installing Lazygit"

    local coprs=(
        atim/lazygit                       # Lazygit COPR repository
    )

    enable_coprs "${coprs[@]}"

    local packages=(
        lazygit                            # Terminal UI for Git
    )

    install_packages "${packages[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Development runtimes
# ─────────────────────────────────────────────────────────────────────────────

install_development_runtimes() {
    msg "installing development runtimes through mise"

    if ! command -v mise >/dev/null 2>&1; then
        die "mise is not available in PATH"
    fi

    # Make mise available to this non-interactive shell.
    eval "$(mise activate bash)"

    # will use the ~/.config/mise/config.toml file to install the runtimes
    mise install
}


# ─────────────────────────────────────────────────────────────────────────────
# Applications
# ─────────────────────────────────────────────────────────────────────────────

install_foot() {
    msg "installing Foot terminal"

    local packages=(
        foot                               # Lightweight Wayland terminal emulator
    )

    install_packages "${packages[@]}"
}


install_brave() {
    msg "installing Brave browser"

    local repositories=(
        "https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo" # Brave DNF repository
    )

    for repository in "${repositories[@]}"; do
        sudo dnf config-manager addrepo --from-repofile="$repository"
    done

    local keys=(
        "https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"    # Brave repository signing key
    )

    for key in "${keys[@]}"; do
        sudo rpm --import "$key"
    done

    local packages=(
        brave-browser                      # Chromium-based web browser
    )

    install_packages "${packages[@]}"
}


install_noctalia() {
    msg "installing Noctalia"

    local packages=(
        noctalia-git                       # Wayland desktop shell
    )

    install_packages "${packages[@]}"
}


install_herdr() {
    msg "installing Herdr"

    local installers=(
        "https://herdr.dev/install.sh"     # Herdr installation script
    )

    for installer in "${installers[@]}"; do
        curl -fsSL "$installer" | sh
    done
}


# ─────────────────────────────────────────────────────────────────────────────
# Fonts
# ─────────────────────────────────────────────────────────────────────────────

install_fonts() {
    msg "installing fonts"

    local packages=(
        jetbrains-mono-fonts               # Monospaced programming font
        cascadia-code-fonts                # Microsoft's programming font
        fira-code-fonts                    # Programming font with ligatures
        google-noto-sans-fonts             # General-purpose sans-serif font
        google-noto-serif-fonts            # General-purpose serif font
        google-noto-emoji-fonts            # Unicode emoji font
        adobe-source-code-pro-fonts        # Monospaced programming font
        liberation-fonts                   # Metric-compatible replacement fonts
    )

    install_packages "${packages[@]}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Flatpak
# ─────────────────────────────────────────────────────────────────────────────

configure_flatpak() {
    msg "configuring Flathub"

    local remotes=(
        "https://dl.flathub.org/repo/flathub.flatpakrepo" # Flathub repository
    )

    for remote in "${remotes[@]}"; do
        sudo flatpak remote-add \
            --if-not-exists \
            flathub \
            "$remote"
    done

    sudo flatpak update -y
}


install_flatpak_apps() {
    msg "installing Flatpak applications"

    local apps=(
        com.valvesoftware.Steam              # Steam gaming client
        com.discordapp.Discord               # Discord chat application
    )

    for app in "${apps[@]}"; do
        install_flatpak "$app"
    done
}


# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles
# ─────────────────────────────────────────────────────────────────────────────

checkout_dotfiles() {
    msg "checking out dotfiles"

    mkdir -p "$(dirname "$DOTFILES_DIR")"

    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        git -C "$DOTFILES_DIR" pull --ff-only
    else
        git clone \
            https://github.com/franckyj/my-dotfiles.git \
            "$DOTFILES_DIR" ||
            die "Failed to checkout my-dotfiles"
    fi
}


make_scripts_executable() {
    msg "making dotfiles scripts executable"

    if [[ -d "$DOTFILES_DIR/scripts" ]]; then
        find "$DOTFILES_DIR/scripts" \
            -type f \
            -exec chmod +x {} \;
    fi
}


install_dotfiles() {
    msg "creating dotfile symlinks with Stow"

    local stow_packages=(
        foot                              # Foot terminal configuration
        git                               # Git configuration
        helix                             # Helix editor configuration
        herdr                             # Herdr configuration
        hyprland                          # Hyprland configuration
        mise                              # mise configuration
        starship                          # Starship prompt configuration
        zsh                               # Zsh configuration
    )

    for package in "${stow_packages[@]}"; do
        stow \
            -d "$DOTFILES_DIR" \
            -v \
            -t "$HOME" \
            "$package" \
            --dotfiles ||
            die "Failed to create symlinks with Stow - [$package]"
    done
}


# ─────────────────────────────────────────────────────────────────────────────
# Wallpapers
# ─────────────────────────────────────────────────────────────────────────────

install_wallpapers() {
    msg "checking out wallpapers from MyLinuxForWork"

    local wallpapers="$HOME/Pictures/Wallpapers"

    mkdir -p "$HOME/Pictures"

    if [[ -d "$wallpapers/.git" ]]; then
        git -C "$wallpapers" pull --ff-only
    elif [[ -e "$wallpapers" ]]; then
        warn "$wallpapers already exists and is not a Git repository; skipping wallpaper installation"
    else
        git clone \
            https://github.com/mylinuxforwork/wallpaper.git \
            "$wallpapers"
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# System services
# ─────────────────────────────────────────────────────────────────────────────

enable_ssd_trim() {
    msg "enabling SSD TRIM"

    sudo systemctl enable --now fstrim.timer
}


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

main() {
    msg "──────────────────────────────────────────"
    msg " Fedora 44 Post-Install Setup"
    msg "──────────────────────────────────────────"

    check_environment

    configure_dnf
    update_system
    enable_rpmfusion
    update_firmware

    enable_hyprland_copr
    install_hyprland

    install_multimedia
    install_intel_media_driver
    # install_freeworld_drivers

    install_basic_utilities

    install_shell
    install_starship
    install_atuin

    install_development_tools
    install_lazygit

    install_foot
    install_brave
    install_fonts
    install_noctalia
    install_herdr

    configure_flatpak
    install_flatpak_apps

    checkout_dotfiles
    make_scripts_executable
    install_dotfiles

    install_development_runtimes

    install_wallpapers

    enable_ssd_trim

    success "──────────────────────────────────────────"
    success " Installation completed successfully!"
    success " Installation completed successfully!"
    success "──────────────────────────────────────────"

    msg "Reboot your system to apply all changes."
}

main "$@"
