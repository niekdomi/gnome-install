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

# Set themes
install_theme
#
# Extensions
gnome_extension

# Configs
gnome_config
