#!/usr/bin/env bash
# Windows 11 Look & Taskbar – Install / Reinstall Script
# CachyOS / Arch / KDE Plasma 6
# Safe to run multiple times

set -e

echo "=================================================="
echo " Windows 11 Look – Install / Reinstall (KDE) "
echo "=================================================="

### Safety check
if [[ "$EUID" -eq 0 ]]; then
  echo "❌ Do NOT run this script as root."
  exit 1
fi

### 1️⃣ System update
echo "[1/9] Updating system..."
sudo pacman -Syu --noconfirm

### 2️⃣ Core KDE packages (repair-safe)
echo "[2/9] Installing core KDE dependencies..."
sudo pacman -S --needed --noconfirm \
git \
wget \
unzip \
plasma-desktop \
kde-cli-tools \
systemsettings \
kde-gtk-config \
papirus-icon-theme \
kvantum

### 3️⃣ Ensure yay (AUR helper)
echo "[3/9] Checking yay..."
if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed --noconfirm base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

### 4️⃣ Fonts & cursor (reinstall-safe)
echo "[4/9] Installing fonts and cursor..."
yay -S --needed --noconfirm \
ttf-segoe-ui-variable \
ttf-consolas \
bibata-cursor-theme

### 5️⃣ Windows 11 Icon Theme (working repo)
echo "[5/9] Installing Windows 11 icon theme..."
if [ ! -d "/usr/share/icons/Win11" ]; then
  git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icons
  (cd /tmp/win11-icons && sudo ./install.sh)
else
  echo "✔ Win11 icon theme already installed"
fi

### 6️⃣ Windows 11 KDE Global Theme (OFFICIAL repo)
echo "[6/9] Installing Windows 11 KDE Global Theme..."
git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/win11os-kde
(cd /tmp/win11os-kde && sudo ./install.sh)

### 7️⃣ Apply Windows 11 appearance
echo "[7/9] Applying Windows 11 appearance..."

# Icons
plasma-apply-icons Win11 || plasma-apply-icons Papirus || true

# Cursor
plasma-apply-cursortheme Bibata-Modern-Ice 24 || true

# Fonts
kwriteconfig6 --file kdeglobals --group General --key font "Segoe UI Variable,10,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kdeglobals --group General --key fixed "Consolas,10,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "Segoe UI Variable,9,-1,5,50,0,0,0,0,0"

# Windows-like behavior
kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true

### 8️⃣ Reload Plasma safely
echo "[8/9] Reloading Plasma..."
qdbus org.kde.KWin /KWin reconfigure || true
plasmashell --replace &>/dev/null & disown

### 9️⃣ Cleanup
echo "[9/9] Cleanup..."
rm -rf /tmp/win11-icons /tmp/win11os-kde /tmp/yay

echo
echo "=================================================="
echo " ✅ INSTALL / REINSTALL COMPLETE"
echo "=================================================="
echo
echo "FINAL MANUAL STEP (Plasma limitation):"
echo "• Right-click panel → Edit Mode"
echo "• Bottom | Height ~46px"
echo "• Enable Floating Panel"
echo "• Icons-only Task Manager (centered)"
echo
echo "💡 Script is SAFE to re-run anytime."
echo
