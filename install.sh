#!/bin/bash

# Color Definitions
RED='\033[0;31m'       # Errors
ORANGE='\033[0;33m'    # System information / Title
YELLOW='\033[1;33m'    # Packages
GREEN='\033[0;32m'     # Success
LIGHTBLUE='\033[1;34m' # Configs
NC='\033[0m'           # No Color (reset to default value)

# Variables
install_applications=true
install_gnome_extensions=true
install_fonts=true
install_VM=false
apply_configs=true

# Include files
gnome_applications="gnome.txt"

install_app() {
    local file="$1"

    # Check if the file exists
    if [[ -f "$file" ]]; then
        while IFS= read -r application; do
            # Remove inline comments and trim whitespace
            application=$(echo "$application" | sed 's/#.*//' | xargs)

            # Skip empty lines
            [[ -z "$application" ]] && continue

            echo -e "${YELLOW}Installing $application...${NC}"
            yay -S "$application" --noconfirm >/dev/null 2>&1
            echo -e "${GREEN}Installed $application${NC}"
        done <"$file"
    else
        echo -e "${RED}Error: File '$file' not found.${NC}"
        exit 1
    fi
}

install_app "$gnome_applications"
