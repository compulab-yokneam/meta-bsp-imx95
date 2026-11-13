# NetworkManager configures the network interfaces.
SYSTEMD_AUTO_ENABLE:${PN}-networkd = "disable"

# Suppress OSC 3008 shell prompt hooks without patching systemd sources.
PACKAGECONFIG:remove = "osc-context"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://10-disable-osc-context.conf"

do_install:append() {
    install -D -m 0644 ${UNPACKDIR}/10-disable-osc-context.conf \
        ${D}${systemd_system_unitdir}/serial-getty@.service.d/10-disable-osc-context.conf
}

FILES:${PN} += "${systemd_system_unitdir}/serial-getty@.service.d/10-disable-osc-context.conf"
