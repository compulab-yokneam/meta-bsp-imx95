SRC_URI:append = " \
    ${@bb.utils.contains('DRAM_CONF', 'D4', 'file://d4.cfg', '', d)} \
"
SRC_URI:append = " \
    ${@bb.utils.contains('DRAM_CONF', 'D8', 'file://d8.cfg', '', d)} \
"
SRC_URI:append = " \
    ${@bb.utils.contains('DRAM_CONF', 'D16', 'file://d16.cfg', '', d)} \
"

SRC_URI:append:mcm-imx95-sbc = " file://mcm-imx95.cfg file://mcm-imx95-sbc.cfg "
