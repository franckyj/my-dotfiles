#!/usr/bin/env bash
# from https://codeberg.org/justaguylinux/oxwm-setup/src/branch/main/install.sh

# fail immediately if any command fails
set -euo pipefail

# if [[ $EUID -eq 0 ]]; then
#     die "Do not run this script as root."
# fi

# if ! command -v sudo >/dev/null 2>&1; then
#     die "sudo is required."
# fi

# colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARNING: $*${NC}" >&2; }
msg() { echo -e "${CYAN}$*${NC}"; }

msg "──────────────────────────────────────────"
msg " Fedora 44 Post-Install Setup"
msg "──────────────────────────────────────────"

# paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# TEMP_DIR="/tmp/oxwm_$$"
LOG_FILE="$HOME/fedora-install.log"

# logging function
exec > >(tee -a "$LOG_FILE") 2>&1

# cleanup function to remove temporary files
# trap "rm -rf $TEMP_DIR" EXIT

msg "add settings to the /etc/dnf/dnf.conf file"
grep -q 'max_parallel_downloads' /etc/dnf/dnf.conf || {
  echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
  echo 'fastestmirror=True'        | sudo tee -a /etc/dnf/dnf.conf
  # echo 'defaultyes=True'           | sudo tee -a /etc/dnf/dnf.conf
  echo 'keepcache=True'            | sudo tee -a /etc/dnf/dnf.conf
}

msg "update the system"
sudo dnf upgrade --refresh -y

sudo dnf install -y dnf-plugins-core

msg "update the firmware"
sudo fwupdmgr refresh
sudo fwupdmgr get-devices
sudo fwupdmgr get-updates
# sudo fwupdmgr update

msg "enable RPM fusion"
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# run these to analyze the boot time and optimze afterward
# total boot time breakdown
# systemd-analyze
# ranked list of services by startup time
# systemd-analyze blame
# systemd-analyze blame | head -15
# msg "optimize boot time"
# sudo systemctl disable NetworkManager-wait-online.service
# sudo systemctl disable plymouth-quit-wait.service

msg "install lionheartp copr for hyprland"
sudo dnf copr enable lionheartp/Hyprland

msg "install ffmpeg"
sudo dnf install -y \
    ffmpeg \
    ffmpeg-libs libva libva-utils \
    intel-media-driver

msg "install multimedia codecs"
sudo dnf4 group install multimedia
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video # installs useful Sound and Video complementary packages.

msg "swap old for new drivers"
sudo dnf swap ffmpeg-free ffmpeg --allowerasing # switch to full FFMPEG.
sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing

# here
if lspci | grep -qi 'Intel.*VGA\|Intel.*Display'; then
    sudo dnf install -y intel-media-driver
fi

sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

msg "install sound codecs"
sudo dnf install -y libfreeaptx libldac fdk-aac

msg "install basic utilities (git, curl, etc.)"
sudo dnf install -y git curl wget unzip p7zip p7zip-plugins

# msg "install docker"
# curl -fsSL https://get.docker.com | sudo sh
# sudo systemctl enable --now docker
# sudo usermod -aG docker $USER

msg "install Hyprland and Wayland utilities"

# no hyprpaper since noctalia
sudo dnf install -y \
  hyprland \
  hyprlock \
  hypridle \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  wl-clipboard \
  brightnessctl \
  pipewire \
  wireplumber \
  playerctl \
  pavucontrol \
  qt5-wayland \
  qt6-wayland

msg "install zsh"
# msg "install zsh with oh-my-zsh"
sudo dnf install -y zsh
chsh -s "$(command -v zsh)"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

msg "install foot"
sudo dnf install -y foot

msg "install starship"
curl -sS https://starship.rs/install.sh | sh

msg "install atuin"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# atuin register -u $USER -e you@example.com   # optional, for sync

msg "install a bunch of tools to replace old commands (eza, bat, ripgrep, helix, etc.)"
sudo dnf install -y eza bat ripgrep fd-find zoxide fzf btop htop iotop-c \
  nvtop du-dust duf ncdu fastfetch git-delta jq yq gh tldr neovim helix \
  yazi mise
# lazygit lives in a Copr (not the default Fedora repos):
sudo dnf copr enable -y atim/lazygit
sudo dnf install -y lazygit

msg "install brave browser"
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

msg "install some coding fonts"
sudo dnf install -y \
  jetbrains-mono-fonts cascadia-code-fonts fira-code-fonts \
  google-noto-sans-fonts google-noto-serif-fonts google-noto-emoji-fonts \
  adobe-source-code-pro-fonts liberation-fonts

msg "add flatpak repo"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remotes
sudo flatpak update

msg "steam via Flathub — better sandboxing and more consistent library support"
flatpak install -y flathub com.valvesoftware.Steam

msg "install discord"
flatpak install -y flathub com.discordapp.Discord

msg "install herdr"
curl -fsSL https://herdr.dev/install.sh | sh

msg "install pi"
curl -fsSL https://pi.dev/install.sh | sh

msg "install noctalia"
sudo dnf install -y noctalia-git

msg "install stow"
sudo dnf install -y stow

msg "creating the dotfiles folder"
mkdir -p $HOME/dev/github/franckyj/{my-dotfiles}

msg "checkout my-dotfiles"
if [[ -d "$HOME/dev/github/franckyj/my-dotfiles/.git" ]]; then
    git -C "$HOME/dev/github/franckyj/my-dotfiles" pull --ff-only
else
    git clone https://github.com/franckyj/my-dotfiles.git "$HOME/dev/github/franckyj/my-dotfiles" || die "Failed to checkout my-dotfiles"
fi

msg "make scripts executable"
find "$HOME/my-dotfiles/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true

msg "create symlinks with stow"

# create a list of stow packages to install
stow_packages=("foot" "gh" "git" "helix" "herdr" "hyprland" "mise" "starship" "zsh")
for package in "${stow_packages[@]}"; do
    stow -d "$HOME/my-dotfiles" -v -t ~ "$package" --dotfiles || die "Failed to create symlinks with stow - [$package]"
done

msg "enable SSD trim"
sudo systemctl enable --now fstrim.timer

msg "installation completed successfully!"
msg "reboot your system to apply all changes."

# sudo dnf autoremove
warn "you can run `sudo fwupdmgr update` after the reboot to update the firmware"

# look at https://github.com/R7rainz/dotfiles/tree/master/.config for dotfiles