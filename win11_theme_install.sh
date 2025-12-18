#!/bin/bash
# Auto Windows 11 Theme Installer for CachyOS (KDE Plasma)

echo "=== Windows 11 Theme Installer for CachyOS ==="

# Step 1: Update system and install dependencies
echo "[1/5] Installing dependencies..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed git kde-cli-tools plasma-desktop latte-dock kvantum-qt5 kvantum-theme-manager --noconfirm

# Step 2: Clone and install Win11 Icon Theme
echo "[2/5] Installing Win11 Icon Theme..."
git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/Win11-icon-theme
cd /tmp/Win11-icon-theme
chmod +x install.sh
sudo ./install.sh

# Step 3: Clone and install Win11 KDE Theme
echo "[3/5] Installing Win11 KDE Theme..."
git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/Win11OS-kde
cd /tmp/Win11OS-kde
chmod +x install.sh
sudo ./install.sh

# Step 4: Optional: Apply Latte Dock for Windows 11 taskbar
echo "[4/5] Installing Latte Dock..."
sudo pacman -S --needed latte-dock --noconfirm

# Step 5: Cleanup
echo "[5/5] Cleaning up temporary files..."
rm -rf /tmp/Win11-icon-theme /tmp/Win11OS-kde

echo "✅ Installation complete!"
echo "You may need to restart Plasma for all changes to apply:"
echo "   kquitapp5 plasmashell && kstart5 plasmashell"
echo "Then open System Settings → Icons & Global Theme to select 'Win11'."
