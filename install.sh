#!/usr/bin/env bash
# from https://codeberg.org/justaguylinux/oxwm-setup/src/branch/main/install.sh

# fail immediately if any command fails
set -e

# paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# CONFIG_DIR="$HOME/.config/oxwm"
TEMP_DIR="/tmp/oxwm_$$"
LOG_FILE="$HOME/oxwm-install.log"

# logging function
exec > >(tee -a "$LOG_FILE") 2>&1

# cleanup function to remove temporary files
trap "rm -rf $TEMP_DIR" EXIT

# colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARNING: $*${NC}" >&2; }
msg() { echo -e "${CYAN}$*${NC}"; }

# install required software
# dotnet
apt install git bat helix herdr discord steam pi brave eza zoxide docker atuin

# creating the folders
mkdir -p $HOME/dev/github/franckyj/{my-dotfiles}

# checkout my-dotfiles
msg "Checking out my-dotfiles..."
git clone https://github.com/franckyj/my-dotfiles.git "$HOME/my-dotfiles" || die "Failed to checkout my-dotfiles"

# make scripts executable
find "$HOME/my-dotfiles/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true

# create symlinks with stow
msg "Creating symlinks with stow..."

# create a list of stow packages to install
stow_packages("git" "helix" "herdr" "bash")
for package in "${stow_packages[@]}"; do
    stow -d "$HOME/my-dotfiles" -v -t ~ "$package" --dotfiles || die "Failed to create symlinks with stow - [$package]"
done

msg "Installation completed successfully!"
msg "Reboot your system to apply all changes."
