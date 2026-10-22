FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/boot-fixes:"
SRC_URI += " \
    file://0001-ucm-imx95-reserve-ele-dma-memory.patch \
    file://0002-ucm-imx95-disable-unavailable-wake-notifications.patch \
"
