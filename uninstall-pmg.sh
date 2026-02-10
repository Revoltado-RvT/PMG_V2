#!/bin/bash
# Uninstall script for PMG
# Version: 3.2

RED='\033[31m'
YELLOW='\033[1;33m'
GREEN='\033[32m'
NO_COLOR='\033[0m'

echo -e "${YELLOW}====================================${NO_COLOR}"
echo -e "${YELLOW}  PMG Uninstaller v3.2${NO_COLOR}"
echo -e "${YELLOW}====================================${NO_COLOR}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or using sudo${NO_COLOR}"
    exit 1
fi

# Confirm uninstallation
echo -e "${YELLOW}This will remove PMG from your system.${NO_COLOR}"
read -p "Are you sure you want to continue? [y/N]: " -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Uninstallation cancelled.${NO_COLOR}"
    exit 0
fi

# Remove PMG binary
echo -e "${YELLOW}[1/3] Removing PMG binary...${NO_COLOR}"
if [ -f /usr/sbin/pmg ]; then
    rm /usr/sbin/pmg
    echo -e "${GREEN}[✓] PMG binary removed${NO_COLOR}"
else
    echo -e "${YELLOW}[!] PMG binary not found${NO_COLOR}"
fi

# Remove PMG directory
echo -e "${YELLOW}[2/3] Removing PMG directory...${NO_COLOR}"
if [ -d /opt/pmg ]; then
    echo -e "${YELLOW}[!] This will delete all PMG data and logs.${NO_COLOR}"
    read -p "Do you want to remove /opt/pmg directory? [y/N]: " -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf /opt/pmg
        echo -e "${GREEN}[✓] PMG directory removed${NO_COLOR}"
    else
        echo -e "${YELLOW}[!] PMG directory preserved${NO_COLOR}"
    fi
else
    echo -e "${YELLOW}[!] PMG directory not found${NO_COLOR}"
fi

# Final message
echo -e "${YELLOW}[3/3] Cleanup complete${NO_COLOR}"
echo ""
echo -e "${GREEN}====================================${NO_COLOR}"
echo -e "${GREEN}PMG has been uninstalled${NO_COLOR}"
echo -e "${GREEN}====================================${NO_COLOR}"
