FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
EXTRA_OEMAKE += "DDR_CONFIG=lpddr5_timing"

SRC_URI += "file://0001-Add-CompuLab-lpddr5_timing.c.patch"

