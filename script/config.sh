# ------------------------------------- Bluetooth -----------------------------
bluetooth_config() {
    if sudo modprobe btusb; then
        if sudo systemctl start bluetooth && sudo systemctl enable bluetooth; then
            sudo dmesg | grep -i bluetooth
            if sudo systemctl status bluetooth >/dev/null 2>&1; then
                echo -e "${GREEN}\nBluetooth configured successfully...${NC}"
            else
                echo -e "${RED}\nFailed to verify Bluetooth service status...${NC}"
            fi
        else
            echo -e "${RED}\nFailed to start or enable Bluetooth service...${NC}"
        fi
    else
        echo -e "${RED}\nFailed to load btusb module...${NC}"
    fi
}

# ------------------------------------- Printer manager -----------------------
cups_config() {
    echo -e "${YELLOW}\n\nInstalling CUPS...${NC}"
    if sudo pacman -S cups --noconfirm >/dev/null 2>&1; then
        if sudo systemctl start cups.service && sudo systemctl enable cups.service; then
            # Restart avahi
            if sudo systemctl restart avahi-daemon; then
                echo -e "${GREEN}\nCUPS installed and configured successfully...${NC}"
            else
                echo -e "${RED}\nFailed to restart avahi-daemon...${NC}"
            fi
        else
            echo -e "${RED}\nFailed to start or enable CUPS service...${NC}"
        fi
    else
        echo -e "${RED}\nFailed to install CUPS...${NC}"
    fi
}

# ------------------------------------- Configure Git -------------------------
git_config() {
    set +e

    echo -e "${ORANGE}\n\nPlease configure Git user name and email:${NC}"

    # Check if a Git user name is already set
    existingGitUserName=$(git config --global user.name)
    if [ -n "$existingGitUserName" ]; then
        echo "Current Git user name is: $existingGitUserName"
        read -rp "Do you want to keep this user name? (y/n): " keepUserName

        if [ "$keepUserName" != "y" ]; then
            read -rp "Enter new Git user name: " gitUserName
            git config --global user.name "$gitUserName"
        fi
    else
        read -rp "Enter Git user name: " gitUserName
        git config --global user.name "$gitUserName"
    fi

    # Check if a Git email is already set
    existingGitEmail=$(git config --global user.email)
    if [ -n "$existingGitEmail" ]; then
        echo "Current Git email is: $existingGitEmail"
        read -rp "Do you want to keep this email? (y/n): " keepEmail

        if [ "$keepEmail" != "y" ]; then
            read -rp "Enter new Git email: " gitEmail
            git config --global user.email "$gitEmail"
        fi
    else
        read -rp "Enter Git email: " gitEmail
        git config --global user.email "$gitEmail"
    fi

    set -e
}

# ------------------------------------- yay -----------------------------------
yay_config() {
    # Enable review option
    echo -e "${LIGHTBLUE}\n\nEnabling editmenu for yay...${NC}"
    yay --editmenu --save
}

# ------------------------------------- Gnome ---------------------------------
gnome_config() {
    ALL_SETTINGS_FILE="all-dconf.dconf"
    echo -e "${LIGHTBLUE}\nLoading dconf settings...${NC}"

    if [[ -f "$ALL_SETTINGS_FILE" ]]; then
        dconf load / <"$ALL_SETTINGS_FILE"
        echo -e "${GREEN}\ndconf settings restored successfully...${NC}"
    else
        echo -e "${RED}\ndconf file not found...${NC}"
    fi

    echo -e "${LIGHTBLUE}\nLoad background...${NC}"
    mkdir -p ~/.local/share/backgrounds
    if cp -r Catppuccin-pacman "$HOME"/.local/share/backgrounds/; then
        mkdir -p ~/.local/share/gnome-background-properties
        if cp catppuccin-pacman.xml ~/.local/share/gnome-background-properties/; then
            echo -e "${GREEN}\nBackground loaded successfully...${NC}"
        else
            echo -e "${RED}\nFailed to copy XML file...${NC}"
        fi
    else
        echo -e "${RED}\nFailed to copy background...${NC}"
    fi
}

# ------------------------------------- shell ---------------------------------
shell_config() {
    # Change default shell
    echo -e "${LIGHTBLUE}\n\nChanging default shell...${NC}"
    chsh -s /bin/fish
}

start_gdm() {
    # MUST BE THE LAST COMMAND
    sudo systemctl enable --now gdm.service
}

# ------------------------------------- Dotfiles ------------------------------
dotfiles_config() {
    echo -e "${LIGHTBLUE}\n\nConfiguring dotfiles...${NC}"

    if git clone https://github.com/domi413/dotfiles; then
        cd dotfiles || return 1

        config_dirs="btop fastfetch fish ghostty lazygit nvim tealdeer yazi zathura zed starship"

        if cp -r $config_dirs ~/.config/; then
            echo -e "${GREEN}\nDotfiles configured successfully...${NC}"
        else
            echo -e "${RED}\nFailed to copy dotfiles...${NC}"
            return 1
        fi

        cd ..
    else
        echo -e "${RED}\nFailed to clone dotfiles repository...${NC}"
        return 1
    fi
}

# ------------------------------------- Keyd ----------------------------------
keyd_config() {
    echo -e "${LIGHTBLUE}\n\nConfiguring keyd (custom key remapping)...${NC}"

    if ! command -v keyd &>/dev/null; then
        echo -e "${RED}\nkeyd is not installed. Please install keyd first.${NC}"
        return 1
    fi

    if [[ ! -f "default.conf" ]]; then
        echo -e "${RED}\nkeyd configuration file 'default.conf' not found in current directory.${NC}"
        return 1
    fi

    if ! sudo mkdir -p /etc/keyd; then
        echo -e "${RED}\nFailed to create /etc/keyd directory.${NC}"
        return 1
    fi

    echo -e "${YELLOW}\nCopying keyd configuration...${NC}"
    if sudo cp default.conf /etc/keyd/default.conf; then
        sudo chmod 644 /etc/keyd/default.conf
        sudo chown root:root /etc/keyd/default.conf
        echo -e "${GREEN}\nkeyd configuration file copied successfully.${NC}"
    else
        echo -e "${RED}\nFailed to copy keyd configuration file.${NC}"
        return 1
    fi

    echo -e "${YELLOW}\nEnabling and starting keyd service...${NC}"
    if sudo systemctl enable keyd; then
        if sudo systemctl start keyd; then
            echo -e "${GREEN}\nkeyd service enabled and started successfully.${NC}"
        else
            echo -e "${RED}\nFailed to start keyd service.${NC}"
            return 1
        fi
    else
        echo -e "${RED}\nFailed to enable keyd service.${NC}"
        return 1
    fi

    echo -e "${YELLOW}\nReloading keyd configuration...${NC}"
    if sudo keyd reload; then
        echo -e "${GREEN}\nkeyd configuration reloaded successfully.${NC}"
    else
        echo -e "${RED}\nFailed to reload keyd configuration.${NC}"
        return 1
    fi

    if sudo systemctl is-active keyd >/dev/null 2>&1; then
        echo -e "${GREEN}\nkeyd is running and configured successfully.${NC}"
        echo -e "${LIGHTBLUE}\nCapital Lock key is now remapped for vim-style navigation:${NC}"
        echo -e "${LIGHTBLUE}\n  - CapsLock + h/j/k/l = Arrow keys${NC}"
        echo -e "${LIGHTBLUE}\n  - CapsLock + 1-0/-/= = F1-F12${NC}"
        echo -e "${LIGHTBLUE}\n  - CapsLock + Backspace = Delete${NC}"
        echo -e "${LIGHTBLUE}\n  - CapsLock + Escape = Toggle CapsLock${NC}"
    else
        echo -e "${RED}\nkeyd service is not running properly.${NC}"
        return 1
    fi
}
