FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DESCRIPTION = "Enable IMX219 and IMX477 Camera Module in libcamera for i.MX95"

SRC_URI:append = " \
        file://0001-libcamera-Merge-imx219-imx477-build-files-update.patch \
"
