#!/bin/bash
# Windows 11 Look on Cachy OS (KDE Plasma 6) Auto Script
# Run as normal user (not root) for KDE config.

set -e

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Installing KDE Plasma and required applications..."
sudo pacman -S --needed --noconfirm plasma kde-applications git wget unzip

# -------- Ensure yay (AUR helper) exists --------
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
fi

# -------- Install fonts, cursor theme, Latte Dock via yay --------
yay -S --needed --noconfirm \
    ttf-segoe-ui-variable \
    bibata-cursor-theme \
    latte-dock

echo "Creating folders for themes and icons..."
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/plasma/look-and-feel
mkdir -p ~/Pictures

# -------- Download Windows 11 Plasma Theme --------
echo "Downloading Windows 11 Plasma theme..."
rm -f /tmp/win11-theme.zip
wget -O /tmp/win11-theme.zip https://www.pling.com/p/1747351/download
unzip -o /tmp/win11-theme.zip -d ~/.local/share/plasma/desktoptheme/
rm /tmp/win11-theme.zip

# -------- Download Windows 11 Icon Pack --------
echo "Downloading Windows 11 Icons..."
rm -f /tmp/win11-icons.zip
wget -O /tmp/win11-icons.zip https://www.pling.com/p/1761996/download
unzip -o /tmp/win11-icons.zip -d ~/.local/share/icons/
rm /tmp/win11-icons.zip

# -------- Apply Windows 11 Look & Feel --------
echo "Applying Windows 11 theme..."
lookandfeeltool -a org.kde.windows11.desktop || echo "⚠ Theme not found. Make sure the theme folder exists."

# -------- Launch Latte Dock --------
echo "Starting Latte Dock..."
latte-dock & disown

# -------- Set fonts --------
echo "Setting Segoe UI fonts..."
kwriteconfig6 --file kdeglobals --group General --key font "Segoe UI Variable,10,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kdeglobals --group General --key fixed "Meslo LG,10,-1,5,50,0,0,0,0,0"

# -------- Rounded window decorations --------
echo "Setting window decorations to rounded..."
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize "Normal"

# -------- Download and apply Windows 11 wallpaper --------
echo "Downloading Windows 11 wallpaper..."
wget -O ~/Pictures/win11-wallpaper.jpg https://wallpapers.com/download/windows-11-default-wallpaper-1920x1080

qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
 d = allDesktops[i];
 d.wallpaperPlugin = 'org.kde.image';
 d.currentConfigGroup = Array('Wallpaper','org.kde.image','General');
 d.writeConfig('Image', 'file://$HOME/Pictures/win11-wallpaper.jpg');
}
"

echo "✅ Windows 11 customization applied!"
echo "💡 Please log out and log back in for full effect."
