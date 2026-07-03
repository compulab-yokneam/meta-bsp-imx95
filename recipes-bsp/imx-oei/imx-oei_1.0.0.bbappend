FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

OEI_DDR_CONFIG = "${@bb.utils.contains('DRAM_CONF', 'D4', 'lpddr5_timing_4g', '${@bb.utils.contains(\'DRAM_CONF\', \'D16\', \'lpddr5_timing_16g\', \'lpddr5_timing_8g\', d)}', d)}"
OEI_DDR_CONFIG_ECC = "${OEI_DDR_CONFIG}"

SRC_URI += " \
    file://0001-compulab-Update-lpddr5-timing-options-add-4G-8G-and-.patch \
"

SRCREV = "fa9e9a29e8c8939cc360beafd01393ca393e439a"
