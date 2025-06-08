#!/usr/bin/bash

# INFO:
# This is a script that creates a service which will change the theme and icon
# pack for the gnome dark/light mode

gnome_theme_switcher() {
    echo -e "${LIGHTBLUE}\n\nTheme sync service to toggle dark/light (icon) theme will be set up...{NC}"
    sudo tee /usr/local/bin/theme-sync <<"EOF" >/dev/null
#!/usr/bin/bash
gsettings monitor org.gnome.desktop.interface color-scheme \
| while read -r COLOR_SCHEME
do
    case "${COLOR_SCHEME}" in
    (*default*|*prefer-light*)
        GTK_THEME="adw-gtk3"
        ICON_THEME="Papirus-Light" ;;
    (*prefer-dark*)
        GTK_THEME="adw-gtk3-dark"
        ICON_THEME="Papirus-Dark" ;;
    esac
    gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
    gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"
done
EOF

    # Set executable permissions
    sudo chmod +x /usr/local/bin/theme-sync

    # Creating systemd user service
    sudo tee /etc/systemd/user/theme-sync.service <<EOF >/dev/null
[Unit]
Description=Theme sync service for light/dark mode
[Service]
ExecStart=/usr/local/bin/theme-sync
Restart=always
[Install]
WantedBy=gnome-session.target
EOF

    # Reload and enable the service
    systemctl --user daemon-reload
    systemctl --user enable theme-sync.service
    systemctl --user restart theme-sync.service

    echo -e "${GREEN}\nTheme sync service set up successfully...${NC}"
}
