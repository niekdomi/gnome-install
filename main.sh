#!/bin/bash

# Include sources
source "script/config.sh"
source "script/extension.sh"
source "script/install.sh"
source "script/vm.sh"

# Color Definitions
RED='\033[0;31m'       # Errors
ORANGE='\033[0;33m'    # System information / Title
YELLOW='\033[1;33m'    # Packages
GREEN='\033[0;32m'     # Success
LIGHTBLUE='\033[1;34m' # Configs
NC='\033[0m'           # No Color (reset to default value)

# Include application lists
gnome_applications="install/gnome.txt"
terminal_tools="install/terminal.txt"
internet_tools="install/internet.txt"
programming_tools="install/programming.txt"
fun_tools="install/fun.txt"
themes="install/theme.txt"
wine="install/wine.txt"

# Install applications
install_app "$gnome_applications"
install_app "$terminal_tools"
install_app "$internet_tools"
install_app "$programming_tools"
install_app "$fun_tools"
install_app "$themes"
# install_app "$wine"

# Install fonts
install_font

# Set themes
install_theme

# Install & Configure KVM
install_kvm
start_kvm

# Extensions
nautilus_extension
firefox_extension

# Configs
bluetooth_config
cups_config
git_config
yay_config
gnome_config
shell_config
system_config

# Reboot
echo -e "${GREEN}done${NC}"
echo -e "${YELLOW}Rebooting in 10 seconds...${NC}"
sleep 10
reboot
