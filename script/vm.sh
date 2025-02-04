# ------------------------------------- Configure KVM -------------------------
configure_and_start_services() {
    set +e

    echo -e "${GREEN}\nConfiguring and starting necessary services...${NC}"

    # Start and enable libvirtd.service
    echo -e "${YELLOW}\nStarting and enabling libvirtd.service...${NC}"
    sudo systemctl start libvirtd.service
    sudo systemctl enable libvirtd.service

    # Manage the 'default' network
    manage_default_network

    set -e
}

manage_default_network() {
    defaultNetworkActive=$(sudo virsh net-list --all | grep -w default | grep -w active)

    echo -e "${YELLOW}\nThe 'default' network is not active. Starting it...${NC}"
    sudo virsh net-start default

    # defaultNetworkAutostart=$(sudo virsh net-list --all | grep -w default | grep -w yes)

    echo -e "${YELLOW}\nSetting the 'default' network to autostart...${NC}"
    sudo virsh net-autostart default

    # Finally, list all networks to confirm their statuses
    echo -e "${GREEN}\nCurrent network list:${NC}"
    sudo virsh net-list --all
}

# ------------------------------------- Install KVM with QEMU -----------------
install_kvm() {
    echo -e "${YELLOW}\n\nInstalling KVM...${NC}"
    sudo pacman -S virt-manager qemu-full vde2 dnsmasq bridge-utils openbsd-netcat --noconfirm
    configure_and_start_services
}

# ------------------------------------- Start KVM -----------------------------
start_kvm() {
    set +e
    echo -e "${ORANGE}\nConfiguring and starting necessary services...${NC}"

    # Start and enable libvirtd.service
    echo -e "${LIGHTBLUE}\nStarting and enabling libvirtd.service...${NC}"
    sudo systemctl start libvirtd.service
    sudo systemctl enable libvirtd.service

    # Check the 'default' network status more reliably
    defaultNetworkActive=$(sudo virsh net-list --all | grep -w default | grep -w active)

    if [ -z "$defaultNetworkActive" ]; then
        echo -e "${LIGHTBLUE}\nThe 'default' network is not active. Starting it...${NC}"
        sudo firewall-cmd --reload
        sudo virsh net-start default
    else
        echo -e "${ORANGE}\nThe 'default' network is already active.${NC}"
    fi

    # Ensure the 'default' network is set to autostart
    defaultNetworkAutostart=$(sudo virsh net-list --all | grep -w default | grep -w yes)

    if [ -z "$defaultNetworkAutostart" ]; then
        echo -e "${LIGHTBLUE}\nSetting the 'default' network to autostart...${NC}"
        sudo virsh net-autostart default
    else
        echo -e "${ORANGE}\nThe 'default' network is already set to autostart.${NC}"
    fi
}
