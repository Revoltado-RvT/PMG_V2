#!/bin/bash
# Auto-install script for PMG
# Version: 3.2

RED='\033[31m'
YELLOW='\033[1;33m'
GREEN='\033[32m'
NO_COLOR='\033[0m'

echo -e "${GREEN}====================================${NO_COLOR}"
echo -e "${GREEN}  PMG Auto-Installer v3.2${NO_COLOR}"
echo -e "${GREEN}====================================${NO_COLOR}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or using sudo${NO_COLOR}"
    exit 1
fi

# Download PMG script
echo -e "${YELLOW}[1/4] Downloading PMG...${NO_COLOR}"
if wget -q --show-progress -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg; then
    echo -e "${GREEN}[✓] PMG downloaded successfully${NO_COLOR}"
else
    echo -e "${RED}[✗] Failed to download PMG${NO_COLOR}"
    exit 1
fi

# Make PMG executable
echo -e "${YELLOW}[2/4] Making PMG executable...${NO_COLOR}"
chmod +x /usr/sbin/pmg
echo -e "${GREEN}[✓] PMG is now executable${NO_COLOR}"

# Create PMG directory
echo -e "${YELLOW}[3/4] Creating PMG directory...${NO_COLOR}"
mkdir -p /opt/pmg
echo -e "${GREEN}[✓] PMG directory created${NO_COLOR}"

# Test PMG installation
echo -e "${YELLOW}[4/4] Testing PMG installation...${NO_COLOR}"
if pmg version; then
    echo -e "${GREEN}[✓] PMG installed successfully!${NO_COLOR}"
    echo ""
    echo -e "${GREEN}====================================${NO_COLOR}"
    echo -e "${GREEN}Installation completed!${NO_COLOR}"
    echo -e "${GREEN}====================================${NO_COLOR}"
    echo ""
    echo -e "You can now use PMG with the following commands:"
    echo -e "  ${YELLOW}pmg search qemu${NO_COLOR} - Search for QEMU images"
    echo -e "  ${YELLOW}pmg pull qemu <id>${NO_COLOR} - Download a QEMU image"
    echo -e "  ${YELLOW}pmg help${NO_COLOR} - Show help message"
    echo ""
else
    echo -e "${RED}[✗] PMG installation failed${NO_COLOR}"
    exit 1
fi
