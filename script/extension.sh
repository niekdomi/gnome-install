# ------------------------------------- Nautilus extensions -------------------
nautilus_extension() {
    echo -e "${YELLOW}\n\nInstalling Nautilus extensions...${NC}"
    yay -S nautilus-python

    # Copy path
    git clone https://github.com/chr314/nautilus-copy-path.git >/dev/null 2>&1
    cd nautilus-copy-path || exit
    make install >/dev/null 2>&1
    cd ..
    rm -rf nautilus-copy-path

    echo -e "${GREEN}\nAll extensions have been installed.${NC}"
}

# ------------------------------------- Firefox plugins -----------------------
firefox_extension() {
    # Go to https://addons.mozilla.org/en-US/firefox/
    # and search for a plugin you want to install.
    # Right-click the "Add to Firefox"-Button and copy link

    # To get the plugin ID:
    #   - go to about:memory
    #   - under "Show memory reports" -> Measure
    #   - Filter for "moz-extension"

    echo -e "${YELLOW}\n\nInstalling Firefox plugins...${NC}"

    # Define extension URLs and their IDs
    declare -A extensions=(
        # Youtube Dislike
        ["{762f9885-5a13-4abd-9c77-433dcd38b8fd}"]="https://addons.mozilla.org/firefox/downloads/file/4208483/return_youtube_dislikes-3.0.0.14.xpi"

        # Nyan Cat
        ["{c3348e96-6d84-47dc-8252-4b8493299efc}"]="https://addons.mozilla.org/firefox/downloads/file/3975526/nyan_cat_youtube_enhancement-3.0.xpi"

        # Vimium
        ["{d7742d87-e61d-4b78-b8a1-b469842139fa}"]="https://addons.mozilla.org/firefox/downloads/file/4259790/vimium_ff-2.1.2.xpi"

        # Dark Reader
        ["addon@darkreader.org"]="https://addons.mozilla.org/firefox/downloads/file/4249607/darkreader-4.9.80.xpi"

        # uBlock Origin
        ["uBlock0@raymondhill.net"]="https://addons.mozilla.org/firefox/downloads/file/4237670/ublock_origin-1.56.0.xpi"

        # Bitwarden
        ["{446900e4-71c2-419f-a6a7-df9c091e268b}"]="https://addons.mozilla.org/firefox/downloads/file/4326285/bitwarden_password_manager-2024.7.1.xpi"

        # CookieAutoDelete
        ["CookieAutoDelete@kennydo.com"]="https://addons.mozilla.org/firefox/downloads/file/4040738/cookie_autodelete-3.8.2.xpi"
    )

    # Ensure the Firefox distribution extensions directory exists
    firefox_dist_path="/lib/firefox/distribution/extensions" && sudo mkdir -p "$firefox_dist_path"

    # Loop through the extensions array and process each item
    for id in "${!extensions[@]}"; do
        url="${extensions[$id]}"
        file_name=$(basename "$url")
        save_path="$firefox_dist_path/$id.xpi"
        echo -e "${YELLOW}Downloading and installing $file_name with ID $id...${NC}"

        # Download the .xpi file using its ID as the file name
        sudo wget -O "$save_path" "$url" >/dev/null 2>&1 && echo -e "${GREEN}Installed $file_name to $save_path${NC}"
    done

    echo -e "${GREEN}\nAll extensions have been installed.${NC}"
}

# ------------------------------------- Gnome extensions ----------------------
gnome_extension() {
    array=(
        https://extensions.gnome.org/extension/5895/app-hider/                            # App Hider
        https://extensions.gnome.org/extension/615/appindicator-support/                  # AppIndicator
        https://extensions.gnome.org/extension/3193/blur-my-shell/                        # Blur My Shell
        https://extensions.gnome.org/extension/517/caffeine/                              # Caffeine
        https://extensions.gnome.org/extension/3396/color-picker/                         # Color Picker
        https://extensions.gnome.org/extension/307/dash-to-dock/                          # Dash to Dock
        https://extensions.gnome.org/extension/4655/date-menu-formatter/                  # Date Menu Formatter
        https://extensions.gnome.org/extension/755/hibernate-status-button/               # Hibernate Status Button
        https://extensions.gnome.org/extension/4470/media-controls/                       # Media Controls
        https://extensions.gnome.org/extension/3795/notification-timeout/                 # Notification Timeout
        https://extensions.gnome.org/extension/6000/quick-settings-audio-devices-renamer/ # Quick Settings Audio Devices Renamer
        https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/        # Status Area Horizontal Spacing
        https://extensions.gnome.org/extension/7065/tiling-shell/                         # Tiling Shell
        https://extensions.gnome.org/extension/1414/unblank/                              # Unblank
        https://extensions.gnome.org/extension/1460/vitals/                               # Vitals
    )

    for i in "${array[@]}"; do
        EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
        VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
        wget -O "${EXTENSION_ID}".zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG" >/dev/null 2>&1
        gnome-extensions install --force "${EXTENSION_ID}".zip >/dev/null 2>&1
        if ! gnome-extensions list | grep --quiet "${EXTENSION_ID}"; then
            busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "${EXTENSION_ID}"
        fi
        gnome-extensions enable "${EXTENSION_ID}"
        rm "${EXTENSION_ID}".zip
    done
}
