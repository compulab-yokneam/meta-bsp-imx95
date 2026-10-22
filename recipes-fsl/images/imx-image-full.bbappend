# NetworkManager owns network configuration and DHCP in this image.
# Apply after package installation, including all vendor service presets.
ROOTFS_POSTPROCESS_COMMAND += "ucm_networkmanager_only; "

ucm_networkmanager_only() {
    netdir="${IMAGE_ROOTFS}${sysconfdir}/NetworkManager"
    presetdir="${IMAGE_ROOTFS}${sysconfdir}/systemd/system-preset"
    install -d $netdir/conf.d
    printf '[main]\ndhcp=internal\n' \
        > $netdir/conf.d/20-ucm-dhcp.conf

    install -d "$presetdir"
    cat > $presetdir/00-ucm-network-manager.preset <<'PRESET'
# NetworkManager is the network and DHCP owner.
disable dhcpcd.service
disable dhcpcd@.service
disable systemd-networkd.service
disable systemd-networkd.socket
disable systemd-networkd-varlink.socket
disable systemd-networkd-resolve-hook.socket
disable systemd-networkd-wait-online.service
disable systemd-network-generator.service
PRESET

    systemctl --root=${IMAGE_ROOTFS} disable \
        dhcpcd.service systemd-networkd.service systemd-networkd.socket \
        systemd-networkd-varlink.socket systemd-networkd-resolve-hook.socket \
        systemd-networkd-wait-online.service systemd-network-generator.service
    systemctl --root=${IMAGE_ROOTFS} enable NetworkManager.service
}
