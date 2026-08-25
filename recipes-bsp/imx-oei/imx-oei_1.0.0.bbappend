FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

OEI_DDR_CONFIG:compulab-mx95:lpddr5 = "${@bb.utils.contains('DRAM_CONF', 'D4', 'lpddr5_timing_4g', bb.utils.contains('DRAM_CONF', 'D16', 'lpddr5_timing_16g', 'lpddr5_timing_8g', d), d)}"

OEI_DDR_CONFIG:compulab-mx95:lpddr4x = "${@bb.utils.contains('DRAM_CONF', 'D4', 'lpddr4x_timing_4g', 'lpddr4x_timing_8g', d)}"
OEI_DDR_CONFIG_ECC:compulab-mx95 = "${OEI_DDR_CONFIG}"

python () {
    machine_overrides = (d.getVar('MACHINEOVERRIDES') or '').split(':')
    if ('compulab-mx95' in machine_overrides and
            d.getVar('DDR_TYPE') == 'lpddr4x' and
            d.getVar('DRAM_CONF') not in ('D4', 'D8')):
        bb.fatal("LPDDR4X on CompuLab i.MX95 supports only DRAM_CONF "
                 "= 'D4' or 'D8' (configured: '%s')" %
                 d.getVar('DRAM_CONF'))
}

SRC_URI:append:compulab-mx95:lpddr5 = " \
    file://0001-compulab-dram-Add-lpddr5-timing-options-for-4G-8G-an.patch \
"

SRC_URI:append:compulab-mx95:lpddr4x = " \
    file://0001-compulab-dram-Add-lpddr4-timing-options-for-4G.patch \
    file://0002-compulab-dram-Add-lpddr4-timing-options-for-8G.patch \
"

OEI_DDR_CONFIG:compulab-mx952 = "${@bb.utils.contains('DRAM_CONF', 'D4', 'lpddr5_timing_4g', bb.utils.contains('DRAM_CONF', 'D16', 'lpddr5_timing_16g', 'lpddr5_timing_8g', d), d)}"
OEI_DDR_CONFIG_ECC:compulab-mx952 = "${OEI_DDR_CONFIG}"

SRC_URI:append:compulab-mx952 = " \
    file://0001-compulab-imx952-dram-Add-lpddr5-timing-options-for-4.patch \
"
