# Suppress pam_systemd OSC metadata without changing its session registration
# or the terminal type inherited by the login shell.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append:class-target = " \
    file://login-osc-context-enter.conf \
    file://login-osc-context-leave.conf \
"

do_install:append:class-target() {
    pam_login="${D}${sysconfdir}/pam.d/login"
    policy="${sysconfdir}/security"
    include='^session[[:space:]]\+include[[:space:]]\+common-session'
    if [ -f "$pam_login" ]; then
        grep -q "$include" "$pam_login" || \
            bbfatal "Missing common-session include in login PAM configuration"
        install -d "${D}$policy"
        install -m 0644 ${UNPACKDIR}/login-osc-context-enter.conf "${D}$policy/"
        install -m 0644 ${UNPACKDIR}/login-osc-context-leave.conf "${D}$policy/"
        entry="session required pam_env.so conffile=$policy/login-osc-context-enter.conf readenv=0"
        leave="session required pam_env.so conffile=$policy/login-osc-context-leave.conf readenv=0"
        sed -i "/$include/i $entry" "$pam_login"
        sed -i "/$include/a $leave" "$pam_login"
    fi
}

FILES:${PN}-base += " \
    ${sysconfdir}/security/login-osc-context-enter.conf \
    ${sysconfdir}/security/login-osc-context-leave.conf \
"
CONFFILES:${PN}-base += " \
    ${sysconfdir}/security/login-osc-context-enter.conf \
    ${sysconfdir}/security/login-osc-context-leave.conf \
"
