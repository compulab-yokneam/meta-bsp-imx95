SRC_URI:append = " \
    ${@bb.utils.contains('DRAM_CONF', 'D4', 'file://d4.cfg', 'file://d8.cfg', d)} \
"
