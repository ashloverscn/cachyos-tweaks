#!/usr/bin/env bash
# Unified Windows 11 KDE Plasma Installer for CachyOS
# Plasma 6 safe | Idempotent | Install + Reset

set -e

if [[ "$EUID" -eq 0 ]]; then
  echo "❌ Do NOT run this script as root."
  exit 1
fi

WIN_ICON_DIR="$HOME/.local/share/icons/windows"
WIN_ICON_FILE="$WIN_ICON_DIR/win11.svg"

ensure_yay() {
  if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi
}

install_win11() {
  echo "=================================================="
  echo " Installing Windows 11 Look (CachyOS KDE Plasma)"
  echo "=================================================="

  sudo pacman -Syu --noconfirm

  sudo pacman -S --needed --noconfirm \
    git wget unzip \
    plasma-desktop kde-cli-tools systemsettings \
    kde-gtk-config papirus-icon-theme kvantum

  ensure_yay

  yay -S --needed --noconfirm \
    ttf-segoe-ui-variable \
    ttf-meslo \
    bibata-cursor-theme

  if [[ ! -d /usr/share/icons/Win11 ]]; then
    rm -rf /tmp/win11-icons
    git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icons
    (cd /tmp/win11-icons && sudo ./install.sh)
  else
    echo "✔ Win11 icon theme already installed"
  fi

  rm -rf /tmp/win11os-kde
  git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/win11os-kde
  (cd /tmp/win11os-kde && sudo ./install.sh)

  mkdir -p "$WIN_ICON_DIR"
  wget -q -O "$WIN_ICON_FILE" \
    https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2021.svg

  lookandfeeltool -a Win11OS-dark || true
  plasma-apply-icons Win11 || true
  plasma-apply-cursortheme Bibata-Modern-Ice 24 || true

  kwriteconfig6 --file kdeglobals --group General \
    --key font "Segoe UI Variable,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General \
    --key fixed "Meslo LG,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General \
    --key smallestReadableFont "Segoe UI Variable,9,-1,5,50,0,0,0,0,0"

  kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
  kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
  kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true

  qdbus org.kde.KWin /KWin reconfigure || true
  plasmashell --replace &>/dev/null & disown

  rm -rf /tmp/win11-icons /tmp/win11os-kde /tmp/yay

  echo
  echo "✅ Windows 11 look installed!"
  echo "➡ Manual step: Set Start icon using the downloaded file:"
  echo "   $WIN_ICON_FILE"
  echo
}

reset_kde() {
  echo "=================================================="
  echo " Resetting KDE Plasma to CachyOS Defaults"
  echo "=================================================="

  kquitapp6 plasmashell 2>/dev/null || true
  sleep 2

  lookandfeeltool -a org.kde.breeze || true
  plasma-apply-icons breeze || true
  plasma-apply-cursortheme Breeze 24 || true

  kwriteconfig6 --file kdeglobals --group General \
    --key font "Noto Sans,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General \
    --key fixed "Noto Sans Mono,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group KDE --key SingleClick true

  rm -f ~/.config/kwinrc ~/.config/kwinrulesrc
  rm -f ~/.config/plasma-org.kde.plasma.desktop-appletsrc
  rm -rf ~/.local/share/icons/Win11*
  rm -rf ~/.local/share/icons/windows

  sudo rm -rf /usr/share/icons/Win11* 2>/dev/null || true

  if command -v yay &>/dev/null; then
    yay -Rns --noconfirm \
      ttf-segoe-ui-variable \
      ttf-meslo \
      bibata-cursor-theme || true
  fi

  rm -rf ~/.cache/plasma* ~/.cache/ksycoca*

  qdbus org.kde.KWin /KWin reconfigure || true
  plasmashell &>/dev/null & disown

  echo "✅ KDE Plasma reset complete."
  echo "💡 Logout & login recommended."
}

while true; do
  echo "=============================================="
  echo " Windows 11 KDE Installer (CachyOS)"
  echo "=============================================="
  echo "1) Install / Reinstall Windows 11 Look"
  echo "2) Reset KDE Plasma to Default"
  echo "3) Exit"
  read -rp "Choose [1-3]: " choice
  case "$choice" in
    1) install_win11 ;;
    2) reset_kde ;;
    3) exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
done
