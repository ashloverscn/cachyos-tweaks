#!/usr/bin/env bash
# Windows 11 Look & Taskbar Setup for CachyOS (KDE Plasma 6)
# Run as NORMAL USER (sudo will be requested)

set -e

echo "=============================================="
echo " Windows 11 Look Installer for CachyOS (KDE) "
echo "=============================================="

### 1️⃣ Update system
echo "[1/7] Updating system..."
sudo pacman -Syu --noconfirm

### 2️⃣ Base packages
echo "[2/7] Installing base packages..."
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

### 3️⃣ Ensure yay
if ! command -v yay &>/dev/null; then
  echo "[3/7] Installing yay..."
  sudo pacman -S --needed --noconfirm base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

### 4️⃣ Fonts & cursor
echo "[4/7] Installing fonts & cursor..."
yay -S --needed --noconfirm \
ttf-segoe-ui-variable \
ttf-consolas \
bibata-cursor-theme

### 5️⃣ Windows 11 Icon Theme (WORKING)
echo "[5/7] Installing Windows 11 icon theme..."
git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icons
(cd /tmp/win11-icons && sudo ./install.sh)

### 6️⃣ Windows 11 KDE Global Theme (CORRECT REPO)
echo "[6/7] Installing Windows 11 KDE Global Theme..."
git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/win11os-kde
(cd /tmp/win11os-kde && sudo ./install.sh)

### 7️⃣ Apply Windows 11 appearance
echo "[7/7] Applying appearance..."

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

### Reload Plasma
echo "Reloading Plasma..."
qdbus org.kde.KWin /KWin reconfigure || true
plasmashell --replace &>/dev/null & disown

### Cleanup
rm -rf /tmp/win11-icons /tmp/win11os-kde /tmp/yay

echo
echo "=============================================="
echo " ✅ INSTALLATION COMPLETE"
echo "=============================================="
echo
echo "FINAL MANUAL STEP (Plasma limitation):"
echo "• Right-click panel → Edit Mode"
echo "• Position: Bottom"
echo "• Height: ~46px"
echo "• Enable Floating Panel"
echo "• Use Icons-only Task Manager (centered)"
echo
