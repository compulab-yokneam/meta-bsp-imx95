# Keep serial login and shell prompts readable in minicom and tmux.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://0001-pam-systemd-allow-disabling-osc-context.patch \
    file://10-disable-osc-context.conf \
"

# Suppress the shell's OSC 3008 prompt hooks.
PACKAGECONFIG:remove = "osc-context"

UCM_SERIAL_GETTY_DROPIN = \
    "${systemd_system_unitdir}/serial-getty@.service.d"

do_install:append() {
    install -d ${D}${UCM_SERIAL_GETTY_DROPIN}
    install -m 0644 ${UNPACKDIR}/10-disable-osc-context.conf \
        ${D}${UCM_SERIAL_GETTY_DROPIN}/10-disable-osc-context.conf
}

FILES:${PN} += "${UCM_SERIAL_GETTY_DROPIN}/10-disable-osc-context.conf"
