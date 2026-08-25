FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://howto.md \
    file://source.me \
    file://m7-set.sh \
"

do_deploy:append() {
    if [ -f "${DEPLOYDIR}/imx-boot" ]; then
        realname=$(basename $(readlink -e ${DEPLOYDIR}/imx-boot))
        ln -s ${realname} ${DEPLOYDIR}/${realname}-${IMX_SOC_REV}-${DRAM_CONF}-${DDR_TYPE}
    fi
}

do_deploy:append:compulab-mx952() {

    install -m 0644 ${UNPACKDIR}/howto.md    ${DEPLOYDIR}/${BOOT_TOOLS}
    sed 's/\.\.\/mkimage_imx8/\.\/mkimage_imx8/g;s/rm -f $(MKIMG)/rm -f/g' ${S}/iMX952/soc.mak > ${DEPLOYDIR}/${BOOT_TOOLS}/Makefile

    ln -sf ${SYSTEM_MANAGER_FIRMWARE_NAME}.bin ${DEPLOYDIR}/${BOOT_TOOLS}/${SYSTEM_MANAGER_FIRMWARE_BASENAME}.bin
    ln -sf ${ATF_MACHINE_NAME} ${DEPLOYDIR}/${BOOT_TOOLS}/bl31.bin
    install -m 0644 ${DEPLOY_DIR_IMAGE}/mcore-demos/${M4_DEFAULT_IMAGE_MX952} ${DEPLOYDIR}/${BOOT_TOOLS}/m7_image.bin

    sed -i "s/@@IMX_SOC_REV@@/${IMX_SOC_REV}/g" ${DEPLOYDIR}/${BOOT_TOOLS}/howto.md
}

do_deploy:append:compulab-mx95() {

    sed 's/\.\.\/mkimage_imx8/\.\/mkimage_imx8/g;s/rm -f $(MKIMG)/rm -f/g' ${S}/iMX95/soc.mak > ${DEPLOYDIR}/${BOOT_TOOLS}/Makefile
    install -m 0644 ${UNPACKDIR}/howto.md    ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${UNPACKDIR}/source.me   ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0755 ${UNPACKDIR}/m7-set.sh   ${DEPLOYDIR}/${BOOT_TOOLS}

    ln -sf ${SYSTEM_MANAGER_FIRMWARE_NAME}.bin ${DEPLOYDIR}/${BOOT_TOOLS}/${SYSTEM_MANAGER_FIRMWARE_BASENAME}.bin
    ln -sf ${ATF_MACHINE_NAME} ${DEPLOYDIR}/${BOOT_TOOLS}/bl31.bin
    ln -sf ${M4_DEFAULT_IMAGE_MX95} ${DEPLOYDIR}/${BOOT_TOOLS}/m7_image.bin

    sed -i "s/@@IMX_SOC_REV@@/${IMX_SOC_REV}/g" ${DEPLOYDIR}/${BOOT_TOOLS}/howto.md
    sed -i "s/@@IMX_SOC_REV@@/${IMX_SOC_REV}/g" ${DEPLOYDIR}/${BOOT_TOOLS}/source.me
}
