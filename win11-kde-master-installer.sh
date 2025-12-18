#!/usr/bin/env bash
# ==================================================
# Windows 11 Look – MASTER Installer for KDE Plasma 6
# CachyOS / Arch Linux
# Install • Reinstall • FULL Reset
# ==================================================

set -e

# ---- Safety check ----
if [[ "$EUID" -eq 0 ]]; then
  echo "❌ Do NOT run as root. Run as normal user."
  exit 1
fi

# ---- Functions ----

install_win11() {
  echo "=================================================="
  echo " Installing / Reinstalling Windows 11 Look "
  echo "=================================================="

  echo "[1/8] Updating system..."
  sudo pacman -Syu --noconfirm

  echo "[2/8] Installing KDE dependencies..."
  sudo pacman -S --needed --noconfirm \
    git wget unzip \
    plasma-desktop kde-cli-tools systemsettings kde-gtk-config \
    papirus-icon-theme kvantum

  echo "[3/8] Ensuring yay..."
  if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi

  echo "[4/8] Installing fonts & cursor..."
  yay -S --needed --noconfirm \
    ttf-segoe-ui-variable \
    ttf-meslo \
    bibata-cursor-theme

  echo "[5/8] Installing Windows 11 icon theme..."
  if [[ ! -d "/usr/share/icons/Win11" ]]; then
    rm -rf /tmp/win11-icons
    git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icons
    (cd /tmp/win11-icons && sudo ./install.sh)
  fi

  echo "[6/8] Installing Windows 11 KDE Global Theme..."
  rm -rf /tmp/win11os-kde
  git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/win11os-kde
  (cd /tmp/win11os-kde && sudo ./install.sh)

  echo "[7/8] Applying Windows 11 appearance..."

  plasma-apply-icons Win11 || plasma-apply-icons Papirus || true
  plasma-apply-cursortheme Bibata-Modern-Ice 24 || true

  kwriteconfig6 --file kdeglobals --group General --key font \
    "Segoe UI Variable,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General --key fixed \
    "Meslo LG,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont \
    "Segoe UI Variable,9,-1,5,50,0,0,0,0,0"

  kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
  kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
  kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true

  echo "[8/8] Reloading Plasma..."
  qdbus org.kde.KWin /KWin reconfigure || true
  plasmashell --replace &>/dev/null & disown

  rm -rf /tmp/win11-icons /tmp/win11os-kde /tmp/yay

  echo
  echo "✅ Windows 11 look INSTALLED / REAPPLIED"
  echo "💡 Manual panel step:"
  echo "   Right-click panel → Edit Mode"
  echo "   Bottom | Height ~46px | Floating"
  echo "   Icons-only Task Manager (centered)"
  echo
}

full_reset_kde() {
  echo "=================================================="
  echo " FULL RESET – Restore KDE Plasma to defaults "
  echo "=================================================="

  echo "⚠️  This will RESET KDE to factory defaults."
  read -rp "Continue? [y/N]: " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || return

  echo "[1/10] Stopping Plasma..."
  kquitapp6 plasmashell 2>/dev/null || true
  sleep 2

  echo "[2/10] Restoring Breeze Look & Feel..."
  lookandfeeltool -a org.kde.breeze || true

  echo "[3/10] Restoring Breeze icons & cursor..."
  plasma-apply-icons breeze || true
  plasma-apply-cursortheme Breeze 24 || true

  echo "[4/10] Restoring default fonts..."
  kwriteconfig6 --file kdeglobals --group General --key font \
    "Noto Sans,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General --key fixed \
    "Noto Sans Mono,10,-1,5,50,0,0,0,0,0"
  kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont \
    "Noto Sans,9,-1,5,50,0,0,0,0,0"

  echo "[5/10] Restoring KDE default behavior..."
  kwriteconfig6 --file kdeglobals --group KDE --key SingleClick true

  echo "[6/10] Removing user Plasma & KWin configs..."
  rm -f ~/.config/kwinrc ~/.config/kwinrulesrc ~/.config/kwinoutputconfig.json
  rm -f ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasmarc ~/.config/plasma-localerc

  echo "[7/10] Removing custom themes, icons & cursors..."
  rm -rf ~/.local/share/plasma/look-and-feel/org.kde.windows11*
  rm -rf ~/.local/share/plasma/desktoptheme/Win11*
  rm -rf ~/.local/share/icons/Win11*
  rm -rf ~/.themes/Win11*
  rm -rf ~/.icons/Bibata*
  sudo rm -rf /usr/share/icons/Win11* 2>/dev/null || true
  sudo rm -rf /usr/share/plasma/look-and-feel/org.kde.windows11* 2>/dev/null || true

  echo "[8/10] Removing Windows fonts & cursors..."
  if command -v yay &>/dev/null; then
    yay -Rns --noconfirm ttf-segoe-ui-variable ttf-meslo bibata-cursor-theme || true
  fi

  echo "[9/10] Clearing KDE caches..."
  rm -rf ~/.cache/plasma* ~/.cache/ksycoca* ~/.cache/kioexec*

  echo "[10/10] Restarting Plasma..."
  qdbus org.kde.KWin /KWin reconfigure || true
  plasmashell &>/dev/null & disown

  echo
  echo "✅ KDE Plasma FULLY RESET to defaults"
  echo "💡 Logout / login recommended"
  echo
}

# ---- Menu ----
while true; do
  echo "=============================================="
  echo " Windows 11 KDE Plasma 6 – MASTER MENU "
  echo "=============================================="
  echo "1) Install / Reinstall Windows 11 Look"
  echo "2) FULL Reset to CachyOS Defaults"
  echo "3) Exit"
  read -rp "Choose [1-3]: " choice
  case "$choice" in
    1) install_win11 ;;
    2) full_reset_kde ;;
    3) exit 0 ;;
    *) echo "Invalid option";;
  esac
done
