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

# AP sharing defaults. Append to the existing imx-image-full.bbappend.
ROOTFS_POSTPROCESS_COMMAND += " \
    ucm_ap_sharing_defaults; \
    ucm_reject_private_wifi_profiles; \
"

ucm_ap_sharing_defaults() {
    netdir="${IMAGE_ROOTFS}${sysconfdir}/NetworkManager"
    presetdir="${IMAGE_ROOTFS}${sysconfdir}/systemd/system-preset"
    connections="$netdir/system-connections"
    install -d $netdir/conf.d
    printf '[main]\nfirewall-backend=iptables\n' \
        > $netdir/conf.d/40-ucm-ap-sharing.conf
    printf '[keyfile]\n%s\n' \
        'unmanaged-devices=interface-name:wlan0;interface-name:wfd0' \
        > $netdir/conf.d/30-ucm-ap-mode.conf

    # NetworkManager starts its own private dnsmasq for shared connections.
    printf 'disable dnsmasq.service\n' \
        >> $presetdir/00-ucm-network-manager.preset
    systemctl --root=${IMAGE_ROOTFS} disable dnsmasq.service

    install -d -m 0700 $connections
    cat > $connections/UCM-AP.nmconnection <<'AP'
[connection]
id=UCM-AP
uuid=9147e084-0848-4a9f-b482-9d322c15ded8
type=wifi
interface-name=uap0
autoconnect=true
autoconnect-priority=50

[wifi]
mode=ap
ssid=UCM-iMX95-AP
band=bg
channel=6
cloned-mac-address=permanent

[wifi-security]
key-mgmt=wpa-psk
proto=rsn;
pairwise=ccmp;
group=ccmp;
psk=Ucm95-12f8c22c1b98

[ipv4]
method=shared
address1=10.42.0.1/24
shared-dhcp-range=10.42.0.10,10.42.0.100
never-default=true

[ipv6]
method=disabled
AP
    chmod 0600 $connections/UCM-AP.nmconnection

    # Fresh images use either Ethernet as upstream, with eth0 preferred.
    for port in 0 1; do
        if [ "$port" = 0 ]; then metric=100; else metric=200; fi
        cat > $connections/UCM-eth$port.nmconnection <<ETHERNET
[connection]
id=UCM-eth$port
type=ethernet
interface-name=eth$port
autoconnect=true
autoconnect-priority=50

[ethernet]

[ipv4]
method=auto
route-metric=$metric
never-default=false

[ipv6]
method=auto
route-metric=$metric
never-default=false
ETHERNET
        chmod 0600 $connections/UCM-eth$port.nmconnection
    done
}

python ucm_reject_private_wifi_profiles() {
    import configparser
    from pathlib import Path
    root = Path(d.getVar('IMAGE_ROOTFS'))
    directory = root / 'etc/NetworkManager/system-connections'
    for path in directory.iterdir():
        if not path.is_file():
            continue
        config = configparser.ConfigParser(interpolation=None, strict=False)
        config.read(path)
        kind = config.get('connection', 'type', fallback='')
        if kind in ('wifi', '802-11-wireless'):
            if (path.name != 'UCM-AP.nmconnection' or
                config.get('wifi', 'mode', fallback='') != 'ap' or
                config.get('wifi', 'ssid', fallback='') != 'UCM-iMX95-AP'):
                bb.fatal(
                    'Personal/upstream Wi-Fi profiles must not be '
                    'packaged in this release image'
                )
    # A local module overlay must never reintroduce the old workaround.
    if any((root / 'lib/modules').glob('*/updates/xt_comment.ko*')):
        bb.fatal('External xt_comment workaround found in rootfs')
}
