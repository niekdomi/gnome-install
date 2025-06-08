#!/bin/bash

# TODO:
# - gnome extension install have to be executed (manually ?) afterwards
# - Fix dotfile script
# - Alias for ghostty to gnome-terminal:  sudo ln -s /usr/bin/ghostty /usr/bin/gnome-terminal

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
fun_tools="install/fun.txt"
gnome_applications="install/gnome.txt"
internet_tools="install/internet.txt"
programming_tools="install/programming.txt"
terminal_tools="install/terminal.txt"
themes="install/theme.txt"
wine="install/wine.txt"

# Install yay before installing anything
install_yay

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
# install_theme

# Install & Configure KVM
# install_kvm
# start_kvm

# Extensions
nautilus_extension
firefox_extension
# gnome_extension

# Configs
bluetooth_config
cups_config
git_config
# gnome_config
yay_config
shell_config
dotfiles_config
gnome_theme_switcher
keyd_config
start_gdm # MUST BE AT THE END
