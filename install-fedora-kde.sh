#!/usr/bin/env bash
#
# Fedora 44 KDE Plasma post-install setup
#
# Keeps developer tooling, shell utilities, Foot, fonts, selected apps,
# dotfiles, Flatpak setup, and firmware/maintenance helpers.
# Assumes Fedora KDE Plasma is already installed.
#
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

readonly FEDORA_VERSION="44"
readonly DOTFILES_DIR="$HOME/dev/github/franckyj/my-dotfiles"
readonly LOG_FILE="$HOME/fedora-install.log"

# ─────────────────────────────────────────────────────────────────────────────
# Colors and output helpers
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die()     { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
warn()    { echo -e "${YELLOW}WARNING: $*${NC}" >&2; }
msg()     { echo -e "${CYAN}$*${NC}"; }
success() { echo -e "${GREEN}$*${NC}"; }

# ─────────────────────────────────────────────────────────────────────────────
# Installation helpers
# ─────────────────────────────────────────────────────────────────────────────

install_packages() {
    sudo dnf install -y "$@"
}

install_flatpak() {
    flatpak install -y flathub "$1"
}

enable_coprs() {
    local coprs=("$@")
    local copr
    for copr in "${coprs[@]}"; do
        sudo dnf copr enable -y "$copr"
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Environment and DNF
# ─────────────────────────────────────────────────────────────────────────────

check_environment() {
    msg "Checking environment"

    [[ $EUID -ne 0 ]] || die "Do not run this script as root."
    command -v sudo >/dev/null 2>&1 || die "sudo is required."
    [[ -f /etc/fedora-release ]] || die "This script is intended for Fedora."

    local detected_version
    detected_version="$(rpm -E %fedora)"
    if [[ "$detected_version" != "$FEDORA_VERSION" ]]; then
        warn "Written for Fedora ${FEDORA_VERSION}; detected Fedora ${detected_version}."
    fi
    sudo -v
}

configure_dnf() {
    msg "Configuring DNF"
    local dnf_conf="/etc/dnf/dnf.conf"
    local settings=(
        "max_parallel_downloads=10"
        "keepcache=True"
    )
    local setting key
    for setting in "${settings[@]}"; do
        key="${setting%%=*}"
        if ! grep -q "^${key}=" "$dnf_conf"; then
            echo "$setting" | sudo tee -a "$dnf_conf" >/dev/null
        fi
    done
}

update_system() {
    msg "Updating system"
    sudo dnf upgrade --refresh -y
    install_packages dnf-plugins-core
}

update_firmware() {
    msg "Firmware updates are not run automatically."
    msg "If supported, check them later with: sudo fwupdmgr refresh && sudo fwupdmgr get-updates"
}

enable_rpmfusion() {
    msg "Enabling RPM Fusion (for multimedia codecs)"
    local repositories=(
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    )
    install_packages "${repositories[@]}"
}

enable_mise_copr() {
    enable_coprs "jdxcode/mise"
}

# ─────────────────────────────────────────────────────────────────────────────
# Multimedia (optional; useful for broader codec support)
# ─────────────────────────────────────────────────────────────────────────────

install_multimedia() {
    msg "Installing multimedia codec support"
    install_packages ffmpeg ffmpeg-libs libva libva-utils libfreeaptx libldac fdk-aac
    sudo dnf group install -y multimedia --setopt="install_weak_deps=False" \
        --exclude=PackageKit-gstreamer-plugin
    sudo dnf group install -y sound-and-video
    sudo dnf swap -y ffmpeg-free ffmpeg
}

install_intel_media_driver() {
    if lspci 2>/dev/null | grep -qiE 'Intel.*(VGA|Display|3D)'; then
        msg "Intel graphics detected; ensuring Intel media driver is installed"
        install_packages intel-media-driver
    else
        msg "Intel graphics not detected; skipping Intel media driver"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Basic utilities and shell
# ─────────────────────────────────────────────────────────────────────────────

install_basic_utilities() {
    msg "Installing basic utilities"
    install_packages git curl wget unzip p7zip p7zip-plugins tar zoxide
}

install_shell() {
    msg "Installing Zsh"
    install_packages zsh
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        msg "Changing the login shell to ${zsh_path}"
        chsh -s "$zsh_path"
    fi
}

install_starship() {
    msg "Installing Starship"
    curl -sS https://starship.rs/install.sh | sh
}

# ─────────────────────────────────────────────────────────────────────────────
# Development tools
# ─────────────────────────────────────────────────────────────────────────────

install_llama_cpp_deps() {
    msg "Installing Vulkan development dependencies for llama.cpp"
    install_packages glslc vulkan-loader vulkan-loader-devel mesa-vulkan-drivers \
        libshaderc spirv-headers-devel vulkan-tools
}

install_development_tools() {
    msg "Installing command-line development tools"
    install_packages duf mise stow flatpak gcc gcc-c++ make cmake ninja-build \
        clang lldb gdb pkgconf-pkg-config openblas-devel
}

install_development_runtimes() {
    msg "Installing runtimes declared in mise config"
    command -v mise >/dev/null 2>&1 || die "mise is not available in PATH"
    eval "$(mise activate bash)"
    mise install
}

# ─────────────────────────────────────────────────────────────────────────────
# Applications and fonts
# ─────────────────────────────────────────────────────────────────────────────

install_foot() {
    msg "Installing Foot terminal"
    install_packages foot
}

install_brave() {
    msg "Installing Brave browser"
    sudo dnf config-manager addrepo \
        --from-repofile="https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo" \
        --overwrite
    sudo rpm --import "https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
    install_packages brave-browser
}

install_zed_editor() {
    msg "Installing Zed editor"
    install_packages zed
}

install_fonts() {
    msg "Installing fonts"
    install_packages jetbrains-mono-fonts jetbrainsmono-nerd-fonts \
        cascadia-code-fonts cascadia-mono-nf-fonts fira-code-fonts \
        firacode-nerd-fonts firamono-nerd-fonts google-noto-sans-fonts \
        google-noto-serif-fonts google-noto-emoji-fonts adobe-source-code-pro-fonts \
        liberation-fonts
}

install_cursor_themes() {
    install_packages bibata-cursor-theme
}

# ─────────────────────────────────────────────────────────────────────────────
# Flatpak
# ─────────────────────────────────────────────────────────────────────────────

configure_flatpak() {
    msg "Configuring Flathub"
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak update -y
}

install_flatpak_apps() {
    msg "Installing selected Flatpak applications"
    local apps=(
        com.valvesoftware.Steam
        com.discordapp.Discord
    )
    local app
    for app in "${apps[@]}"; do
        install_flatpak "$app"
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles and wallpapers
# ─────────────────────────────────────────────────────────────────────────────

checkout_dotfiles() {
    msg "Checking out dotfiles"
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        git -C "$DOTFILES_DIR" pull --ff-only
    else
        git clone https://github.com/franckyj/my-dotfiles.git "$DOTFILES_DIR" ||
            die "Failed to checkout my-dotfiles"
    fi
}

make_scripts_executable() {
    if [[ -d "$DOTFILES_DIR/scripts" ]]; then
        find "$DOTFILES_DIR/scripts" -type f -exec chmod +x {} \;
    fi
}

install_dotfiles() {
    msg "Creating dotfile symlinks with Stow"
    local stow_packages=(
        foot
        git
        helix
        herdr
        mise
        starship
        zsh
        zed
    )
    local package
    for package in "${stow_packages[@]}"; do
        if [[ -d "$DOTFILES_DIR/$package" ]]; then
            stow -d "$DOTFILES_DIR" -v -t "$HOME" "$package" --dotfiles ||
                die "Failed to create symlinks with Stow - [$package]"
        else
            warn "Dotfiles package '$package' not found; skipping"
        fi
    done
}

install_wallpapers() {
    msg "Checking out wallpapers"
    local wallpapers="$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Pictures"
    if [[ -d "$wallpapers/.git" ]]; then
        git -C "$wallpapers" pull --ff-only
    elif [[ -e "$wallpapers" ]]; then
        warn "$wallpapers exists and is not a Git repository; skipping"
    else
        git clone https://github.com/mylinuxforwork/wallpaper.git "$wallpapers"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Optional firmware helpers
# ─────────────────────────────────────────────────────────────────────────────

install_wifi_firmware() {
    msg "Installing Intel Wi-Fi firmware package (only if needed)"
    install_packages iwlwifi-mvm-firmware
}

install_sound_firmware() {
    msg "Installing SOF audio firmware package (only if needed)"
    install_packages alsa-sof-firmware
}

enable_ssd_trim() {
    msg "Enabling periodic SSD TRIM"
    sudo systemctl enable --now fstrim.timer
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

main() {
    msg "──────────────────────────────────────────"
    msg " Fedora 44 KDE Plasma Post-Install Setup"
    msg "──────────────────────────────────────────"

    check_environment
    configure_dnf
    update_system
    enable_rpmfusion
    update_firmware
    install_multimedia
    install_intel_media_driver

    install_basic_utilities
    install_shell
    install_starship

    enable_mise_copr
    install_llama_cpp_deps
    install_development_tools

    install_foot
    install_brave
    install_fonts
    # install_zed_editor
    # install_cursor_themes

    checkout_dotfiles
    make_scripts_executable
    install_dotfiles
    install_development_runtimes

    configure_flatpak
    install_flatpak_apps
    install_wallpapers

    enable_ssd_trim

    # Run these manually only if the hardware needs them:
    # install_wifi_firmware
    # install_sound_firmware

    success "──────────────────────────────────────────"
    success "Installation completed successfully!"
    success "──────────────────────────────────────────"
    msg "Reboot if required by system updates."
}

main "$@"
