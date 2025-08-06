FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://Makefile \
    file://howto.md \
    file://source.me \
"

do_deploy:append:compulab-mx95() {

    install -m 0644 ${UNPACKDIR}/Makefile    ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${UNPACKDIR}/howto.md    ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${UNPACKDIR}/source.me    ${DEPLOYDIR}/${BOOT_TOOLS}

    ln -sf ${SYSTEM_MANAGER_FIRMWARE_NAME}.bin ${DEPLOYDIR}/${BOOT_TOOLS}/${SYSTEM_MANAGER_FIRMWARE_BASENAME}.bin
    ln -sf u-boot-${MACHINE}.bin-sd ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot.bin
    ln -sf u-boot-spl.bin-${MACHINE}-sd ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-spl.bin
    ln -sf ${ATF_MACHINE_NAME} ${DEPLOYDIR}/${BOOT_TOOLS}/bl31.bin
    ln -sf ${M4_DEFAULT_IMAGE_MX95} ${DEPLOYDIR}/${BOOT_TOOLS}/m7_image.bin
}
