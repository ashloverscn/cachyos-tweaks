#!/usr/bin/env bash
# Menu-driven installer / uninstaller for Windows 11 look on CachyOS KDE Plasma
# Plasma 6 safe, idempotent
# Fully fixed: no ttf-consolas, handles leftover folders, proper cleanup

set -e

# Ensure not run as root
if [[ "$EUID" -eq 0 ]]; then
  echo "❌ Do NOT run as root. Use normal user."
  exit 1
fi

# -------- Functions --------

install_win11() {
    echo "=================================================="
    echo " Installing / Reinstalling Windows 11 Look... "
    echo "=================================================="

    # 1️⃣ Update system
    sudo pacman -Syu --noconfirm

    # 2️⃣ Install core KDE packages
    sudo pacman -S --needed --noconfirm \
        git wget unzip plasma-desktop kde-cli-tools systemsettings kde-gtk-config papirus-icon-theme kvantum

    # 3️⃣ Ensure yay
    if ! command -v yay &>/dev/null; then
        sudo pacman -S --needed --noconfirm base-devel
        rm -rf /tmp/yay
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi

    # 4️⃣ Fonts & cursor
    yay -S --needed --noconfirm ttf-segoe-ui-variable ttf-meslo bibata-cursor-theme

    # 5️⃣ Win11 icon theme
    if [ ! -d "/usr/share/icons/Win11" ]; then
        rm -rf /tmp/win11-icons
        git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icons
        (cd /tmp/win11-icons && sudo ./install.sh)
    else
        echo "✔ Win11 icon theme already installed"
    fi

    # 6️⃣ Win11 KDE Global Theme
    rm -rf /tmp/win11os-kde
    git clone https://github.com/yeyushengfan258/Win11OS-kde.git /tmp/win11os-kde
    (cd /tmp/win11os-kde && sudo ./install.sh)

    # 7️⃣ Apply icons, cursor, fonts
    plasma-apply-icons Win11 || plasma-apply-icons Papirus || true
    plasma-apply-cursortheme Bibata-Modern-Ice 24 || true

    kwriteconfig6 --file kdeglobals --group General --key font "Segoe UI Variable,10,-1,5,50,0,0,0,0,0"
    kwriteconfig6 --file kdeglobals --group General --key fixed "Meslo LG,10,-1,5,50,0,0,0,0,0"
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "Segoe UI Variable,9,-1,5,50,0,0,0,0,0"

    kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
    kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true

    # 8️⃣ Reload Plasma
    qdbus org.kde.KWin /KWin reconfigure || true
    plasmashell --replace &>/dev/null & disown

    # 9️⃣ Cleanup
    rm -rf /tmp/win11-icons /tmp/win11os-kde /tmp/yay

    echo
    echo "✅ Windows 11 look installed / reapplied!"
    echo "💡 Manual step: Right-click panel → Edit Mode → Bottom | Height ~46px → Icons-only Task Manager"
    echo
}

reset_kde_default() {
    echo "=================================================="
    echo " Resetting KDE Plasma to CachyOS defaults... "
    echo "=================================================="

    # Kill Plasma safely
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 2

    # Look & Feel
    lookandfeeltool -a org.kde.breeze || true

    # Icons, cursor, fonts
    plasma-apply-icons breeze || true
    plasma-apply-cursortheme Breeze 24 || true

    kwriteconfig6 --file kdeglobals --group General --key font "Noto Sans,10,-1,5,50,0,0,0,0,0"
    kwriteconfig6 --file kdeglobals --group General --key fixed "Noto Sans Mono,10,-1,5,50,0,0,0,0,0"
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "Noto Sans,9,-1,5,50,0,0,0,0,0"
    kwriteconfig6 --file kdeglobals --group KDE --key SingleClick true

    # Remove KWin configs
    rm -f ~/.config/kwinrc ~/.config/kwinrulesrc ~/.config/kwinoutputconfig.json

    # Remove Plasma panel / widgets configs
    rm -f ~/.config/plasma-org.kde.plasma.desktop-appletsrc
    rm -f ~/.config/plasmarc
    rm -f ~/.config/plasma-localerc

    # Remove Win11 themes/icons
    rm -rf ~/.local/share/plasma/look-and-feel/org.kde.windows11*
    rm -rf ~/.local/share/plasma/desktoptheme/Win11*
    rm -rf ~/.local/share/icons/Win11*
    rm -rf ~/.themes/Win11*

    sudo rm -rf /usr/share/icons/Win11* 2>/dev/null || true
    sudo rm -rf /usr/share/plasma/look-and-feel/org.kde.windows11* 2>/dev/null || true

    # Remove extra fonts/cursors installed
    if command -v yay &>/dev/null; then
        yay -Rns --noconfirm ttf-segoe-ui-variable ttf-meslo bibata-cursor-theme || true
    fi

    # Clear caches
    rm -rf ~/.cache/plasma* ~/.cache/kioexec* ~/.cache/ksycoca*

    # Reload Plasma
    qdbus org.kde.KWin /KWin reconfigure || true
    plasmashell &>/dev/null & disown

    echo
    echo "✅ KDE Plasma reset to default CachyOS theme."
    echo "💡 Logout / login recommended to complete reset."
    echo
}

# -------- Menu --------
while true; do
    echo "=============================================="
    echo " Windows 11 KDE Installer / Reset Menu "
    echo "=============================================="
    echo "1) Install / Reinstall Windows 11 Look"
    echo "2) Reset KDE Plasma to Default (CachyOS)"
    echo "3) Exit"
    read -rp "Choose an option [1-3]: " choice
    case "$choice" in
        1) install_win11 ;;
        2) reset_kde_default ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Enter 1, 2, or 3." ;;
    esac
done
