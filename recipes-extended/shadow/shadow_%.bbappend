# login clears the service environment before PAM opens the session.
# Supply the OSC opt-out through pam_env before loading common-session.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append:class-target = " file://login-osc-context.conf"

do_install:append:class-target() {
    pam_login="${D}${sysconfdir}/pam.d/login"
    policy="${sysconfdir}/security/login-osc-context.conf"
    include='^session[[:space:]]\+include[[:space:]]\+common-session'
    if [ -f "$pam_login" ]; then
        grep -q "$include" "$pam_login" || \
            bbfatal "Missing common-session include in login PAM configuration"
        install -d ${D}${sysconfdir}/security
        install -m 0644 ${UNPACKDIR}/login-osc-context.conf "${D}$policy"
        entry="session optional pam_env.so conffile=$policy"
        sed -i "/$include/i $entry" "$pam_login"
    fi
}

FILES:${PN}-base += "${sysconfdir}/security/login-osc-context.conf"
CONFFILES:${PN}-base += "${sysconfdir}/security/login-osc-context.conf"
