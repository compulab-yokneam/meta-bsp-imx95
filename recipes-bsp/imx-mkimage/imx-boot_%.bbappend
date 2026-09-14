FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:compulab-mx95 = " \
    file://howto.md \
    file://m7-set.sh \
"

SRC_URI:append:compulab-mx952 = " \
    file://howto.md \
    file://m7-set.sh \
"

M7_IMAGE:compulab-mx95 = "${M4_DEFAULT_IMAGE_MX95}"
M7_IMAGE:compulab-mx952 = "${M4_DEFAULT_IMAGE_MX952}"

M7_IMAGE_PATTERN:compulab-mx95 = "imx95-19x19-evk_m7_TCM*.bin"
M7_IMAGE_PATTERN:compulab-mx952 = "imx952evk_m7_TCM*.bin"

SOC_DIR:compulab-mx95 = "iMX95"
SOC_DIR:compulab-mx952 = "iMX952"

deploy_compulab_boot_tools() {

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

    sed "s/@@M7_IMAGE_PATTERN@@/${M7_IMAGE_PATTERN}/g" \
        ${UNPACKDIR}/m7-set.sh > ${DEPLOYDIR}/${BOOT_TOOLS}/m7-set.sh
    chmod 0755 ${DEPLOYDIR}/${BOOT_TOOLS}/m7-set.sh
    sed -e "s/@@IMX_SOC_REV@@/${IMX_SOC_REV}/g" \
        -e "s/@@DDR_TYPE@@/${DDR_TYPE}/g" \
        ${UNPACKDIR}/howto.md > ${DEPLOYDIR}/${BOOT_TOOLS}/howto.md
}

do_deploy:append:compulab-mx95() {
    deploy_compulab_boot_tools
}

do_deploy:append:compulab-mx952() {
    deploy_compulab_boot_tools
}
