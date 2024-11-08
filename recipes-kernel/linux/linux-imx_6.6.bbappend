FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-compulab-dts-Add-ucm-imx95.patch \
	file://0002-compulab-dts-Update-ucm-imx95.patch \
	file://0003-compulab-dts-Update-ucm-imx95-00.patch \
	file://0004-debug-ucm-imx95-dts-Add-lvds-stuff-in-the-main-file.patch \
"
