#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${BLUE}Installing Quickshell Dynamic Island Dependencies...${NC}\n"

echo -e "${YELLOW}Syncing pacman databases...${NC}"
sudo pacman -Sy

CORE_PKGS=(
    "wireplumber"
    "brightnessctl"
    "ddcutil"
    "playerctl"
    "networkmanager"
    "bluez-utils"
    "power-profiles-daemon"
    "fd"
    "kitty"
    "python"
    "python-pywal"
    "wl-clipboard"
    "cliphist"
    "jq"          
)

echo -e "\n${YELLOW}Installing core system dependencies from official repos...${NC}"
sudo pacman -S --needed "${CORE_PKGS[@]}"

AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "\n${YELLOW}No AUR helper found (yay/paru). You will need to install Quickshell and bluetuith manually.${NC}"
fi

if [ -n "$AUR_HELPER" ]; then
    echo -e "\n${YELLOW}Installing AUR dependencies via $AUR_HELPER...${NC}"
    $AUR_HELPER -S --needed quickshell bluetuith-bin awww-git
fi

echo -e "\n${YELLOW}Ensuring required system services are enabled...${NC}"

sudo systemctl enable --now NetworkManager

sudo systemctl enable --now bluetooth

sudo systemctl enable --now power-profiles-daemon

echo -e "\n${YELLOW}Configuring ddcutil permissions (may require reboot to take full effect)...${NC}"
sudo modprobe i2c-dev
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null

if ! getent group i2c >/dev/null; then
    sudo groupadd i2c
fi
sudo usermod -aG i2c $USER

echo -e "\n${YELLOW}Initializing files and copying configuration...${NC}"
mkdir -p ~/.config/quickshell
mkdir -p ~/.config/hypr

cp -r ./* ~/.config/quickshell/

if [ -d "./hypr" ]; then
    cp -r ./hypr/* ~/.config/hypr/ 2>/dev/null
    rm -rf ~/.config/quickshell/hypr 2>/dev/null
fi

chmod +x ~/.config/quickshell/components/Scripts/*.sh 2>/dev/null
chmod +x ~/.config/quickshell/components/Scripts/*.py 2>/dev/null
chmod +x ~/.config/quickshell/*.sh 2>/dev/null

echo "compact" > /tmp/island_mode
echo "50" > /tmp/island_vol
echo "100" > /tmp/island_bri
echo "#1e1e2e|#89b4fa" > ~/.config/quickshell/island_colors
echo "0" > ~/.config/quickshell/island_appearance
echo "0" > ~/.config/quickshell/island_layout

echo -e "\n${GREEN}Dependencies successfully installed!${NC}"
echo -e "Note: You have been added to the 'i2c' group for monitor brightness control."
echo -e "You may need to ${BLUE}log out and log back in${NC} for group permissions to apply."