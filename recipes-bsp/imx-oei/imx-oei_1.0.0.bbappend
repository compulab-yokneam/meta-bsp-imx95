FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DDR_CONFIG = "${@bb.utils.contains('DRAM_CONF', 'D4', 'lpddr5_timing_4g', 'lpddr5_timing', d)}"
EXTRA_OEMAKE += "DDR_CONFIG=${DDR_CONFIG}"

SRC_URI += " \
	file://0001-Add-CompuLab-lpddr5_timing.c.patch \
	file://0002-board-mx95lp5-Fix-default-DDR_CONFIG-timing-name.patch \
	file://0003-Add-CompuLab-lpddr5_timing_4g.c.patch \
"
