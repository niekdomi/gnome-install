# ------------------------------------- Bluetooth -----------------------------
bluetooth_config() {
    sudo modprobe btusb
    # pacman -Ss bluetooth
    sudo dmesg | grep -i bluetooth

    # Start bluetooth deamon
    sudo systemctl start bluetooth
    sudo systemctl enable bluetooth
    sudo systemctl status bluetooth
}

# ------------------------------------- Printer manager -----------------------
cups_config() {
    echo -e "${YELLOW}\n\nInstalling CUPS...${NC}"
    sudo pacman -S cups --noconfirm >/dev/null 2>&1

    sudo systemctl start cups.service
    sudo systemctl enable cups.service

    # Restart avahi
    sudo systemctl restart avahi-daemon
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

    # Ensure the file exists before proceeding
    if [[ -f "$ALL_SETTINGS_FILE" ]]; then
        dconf load / <"$ALL_SETTINGS_FILE"
        echo -e "${GREEN}\ndconf settings restored successfully...${NC}"
    else
        echo -e "${RED}\ndconf file not found...${NC}"
    fi

    echo -e "${LIGHTBLUE}\nLoad background...${NC}"
    cp -r ../catppuccin-pacman/ "$HOME"/.local/share/backgrounds
}

# ------------------------------------- shell ---------------------------------
shell_config() {
    # Change default shell
    echo -e "${LIGHTBLUE}\n\nChanging default shell...${NC}"
    chsh -s /bin/fish
}

system_config() {
    # MUST BE THE LAST COMMAND
    sudo systemctl enable --now gdm.service
}

# ------------------------------------- Dotfiles ------------------------------
dotfiles_config() {
    git clone https://github.com/domi413/dotfiles
    cd dotfiles
    ./update_dotfiles.sh -l
}
