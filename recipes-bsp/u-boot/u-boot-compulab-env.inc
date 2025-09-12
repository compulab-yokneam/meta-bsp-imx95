do_install:append () {

	install -d ${D}/etc/
	ln -sf /sys/firmware/devicetree/base/fw_env/fw_env.config ${D}/etc/fw_env.config
	ln -sf /sys/firmware/devicetree/base/fw_env/default_env ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR}
}

UBOOT_INITIAL_ENV = "u-boot-initial-env"
FILES:${PN}-env += "/etc/*"
RDEPENDS:${PN}-env += "bash"
