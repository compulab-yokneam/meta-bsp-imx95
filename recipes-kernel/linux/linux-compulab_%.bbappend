# Build AP-sharing comment matching into the BSP kernel, not an external module.
# Keep the tested NetworkManager firewall-backend=iptables configuration.
# This append is additional to the existing version-specific boot-fix append.

ucm_ap_check_builtin_config() {
    for symbol in CONFIG_NETFILTER_XTABLES CONFIG_NETFILTER_XT_MATCH_COMMENT; do
        grep -qx "$symbol=y" ${B}/.config || \
            bbfatal "AP sharing requires $symbol=y in the kernel configuration"
    done
}

do_configure:append() {
    # Explicitly configure after the vendor's defconfig setup. Do not assume
    # this vendor recipe inherits linux-yocto fragment processing.
    ${S}/scripts/config --file ${B}/.config \
        --enable NETFILTER_XTABLES \
        --enable NETFILTER_XT_MATCH_COMMENT
    oe_runmake -C ${S} O=${B} olddefconfig
    ucm_ap_check_builtin_config
}

# Fail before compilation if another configuration step changes the options.
do_compile[prefuncs] += "ucm_ap_check_builtin_config"
