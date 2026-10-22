# NetworkManager and the installed D-Bus service start wpa_supplicant with -u.
# Apply after vendor configure appends, which replace the generated .config.
do_configure[postfuncs] += "enable_networkmanager_dbus"

enable_networkmanager_dbus() {
    sed -i -e '/^CONFIG_CTRL_IFACE_DBUS_NEW=/d' \
           -e '/^CONFIG_CTRL_IFACE_DBUS_INTRO=/d' \
        ${S}/wpa_supplicant/.config
    printf '\nCONFIG_CTRL_IFACE_DBUS_NEW=y\nCONFIG_CTRL_IFACE_DBUS_INTRO=y\n' \
        >> ${S}/wpa_supplicant/.config
}
