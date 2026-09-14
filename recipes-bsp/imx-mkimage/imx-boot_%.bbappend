FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://howto.md \
    file://source.me \
    file://m7-set.sh \
"

M7_IMAGE:compulab-mx95 = "${M4_DEFAULT_IMAGE_MX95}"
M7_IMAGE:compulab-mx952 = "${M4_DEFAULT_IMAGE_MX952}"

SOC_DIR:compulab-mx95 = "iMX95"
SOC_DIR:compulab-mx952 = "iMX952"

do_deploy:append() {

    sed 's/\.\.\/mkimage_imx8/\.\/mkimage_imx8/g;s/rm -f $(MKIMG)/rm -f/g' ${S}/${SOC_DIR}/soc.mak > ${DEPLOYDIR}/${BOOT_TOOLS}/Makefile

    ln -sf ${SYSTEM_MANAGER_FIRMWARE_NAME}.bin ${DEPLOYDIR}/${BOOT_TOOLS}/${SYSTEM_MANAGER_FIRMWARE_BASENAME}.bin

    if [ ! -f "${DEPLOYDIR}/${BOOT_TOOLS}/${M7_IMAGE}" ];then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/mcore-demos/${M7_IMAGE} ${DEPLOYDIR}/${BOOT_TOOLS}/${M7_IMAGE}
    fi

    ln -sf ${M7_IMAGE} ${DEPLOYDIR}/${BOOT_TOOLS}/m7_image.bin

    if [ -f "${DEPLOYDIR}/imx-boot" ]; then
        realname=$(basename $(readlink -e ${DEPLOYDIR}/imx-boot))
        ln -fs ${realname} ${DEPLOYDIR}/${realname}-${IMX_SOC_REV}-${DRAM_CONF}-${DDR_TYPE}
    fi

    install -m 0644 ${BOOT_STAGING}/u-boot.bin  ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${BOOT_STAGING}/u-boot-spl.bin  ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${BOOT_STAGING}/bl31.bin  ${DEPLOYDIR}/${BOOT_TOOLS}

    install -m 0755 ${UNPACKDIR}/m7-set.sh   ${DEPLOYDIR}/${BOOT_TOOLS}
    sed "s/@@IMX_SOC_REV@@/${IMX_SOC_REV}/g" ${UNPACKDIR}/howto.md > ${DEPLOYDIR}/${BOOT_TOOLS}/howto.md
}
