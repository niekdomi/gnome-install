# ------------------------------------- yay -----------------------------------
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo -e "${YELLOW}Installing yay...${NC}"
        sudo pacman -S --needed git base-devel --noconfirm >/dev/null 2>&1
        git clone https://aur.archlinux.org/yay-bin.git >/dev/null 2>&1
        cd yay-bin || exit
        makepkg -si
        cd ..
        rm -rf yay-bin
        echo -e "${GREEN}Installed yay${NC}"
    else
        echo -e "${ORANGE}yay is already installed.${NC}"
    fi
}

# ------------------------------------- Application ---------------------------
install_app() {
    local file="$1"

    if [[ -f "$file" ]]; then
        while IFS= read -r application; do
            # Remove inline comments and trim whitespace
            application=$(echo "$application" | sed 's/#.*//' | xargs)

            # Skip empty lines
            [[ -z "$application" ]] && continue

            echo -e "${YELLOW}Installing $application...${NC}"
            yay -S "$application" --noconfirm >/dev/null 2>&1
            echo -e "${GREEN}Installed $application${NC}"
            echo "------------------------------"
        done <"$file"
    else
        echo -e "${RED}Error: File '$file' not found.${NC}"
        exit 1
    fi
}

# ------------------------------------- Theme ---------------------------------
install_theme() {
    echo -e "${YELLOW}\n\nInstalling Firefox GTK4 theme...${NC}"
    curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh >/dev/null 2>&1 | bash
    echo -e "${GREEN}Installed Firefox GTK4 theme${NC}"

    echo -e "${YELLOW}\n\nInstalling Thunderbird GTK4 theme...${NC}"
    git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme >/dev/null 2>&1 && cd thunderbird-gnome-theme || exit
    ./scripts/auto-install.sh
    echo -e "${GREEN}Installed Thunderbird GTK4 theme${NC}"
    cd ..
    rm -rf thunderbird-gnome-theme
}

# ------------------------------------- Font -----------------------------------
install_font() {
    font=(
        "ttf-cascadia-code-nerd"
        "ttf-firacode-nerd"
    )

    font_links=(
        # https://github.com/pjobson/Microsoft-365-Fonts
    )

    for font in "${font[@]}"; do
        echo -e "${YELLOW}Installing $font...${NC}"
        yay -S "$font" --noconfirm >/dev/null 2>&1
        echo -e "${GREEN}Installed $font${NC}"
    done

    for link in "${font_links[@]}"; do
        if [[ "$link" == *.zip ]]; then
            repo_name=$(basename "$link")
            echo -e "${YELLOW}\n\nDownloading $link...${NC}"

            download_path="$HOME/Downloads/$repo_name"

            wget -O "$download_path" "$link"
            unzip -o -d "$HOME/Downloads/${repo_name%.*}" "$download_path"

            move_path="$HOME/Downloads/${repo_name%.*}"
        else
            repo_name=$(basename "${link%/*}") # Removes the last part of URL if it's not a .git repository

            echo -e "${YELLOW}\n\nCloning $link into $HOME/Downloads/$repo_name...${NC}"

            # Clone the repository
            git clone --depth 1 "$link" "$HOME/Downloads/$repo_name" 2>/dev/null || echo -e "${RED}Failed to clone $link. Check if the URL is a full repository.${NC}"

            move_path="$HOME/Downloads/${repo_name%.*}"
        fi

        echo -e "${YELLOW}\n\nMoving fonts to /usr/share/fonts/${NC}"
        sudo cp -r "$move_path" /usr/share/fonts/
        rm -rf "$move_path"
    done
}
