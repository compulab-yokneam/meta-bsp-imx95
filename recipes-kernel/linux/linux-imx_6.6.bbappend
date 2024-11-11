FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-compulab-dts-Add-ucm-imx95.patch \
	file://0002-compulab-dts-Update-ucm-imx95.patch \
	file://0003-compulab-dts-Update-ucm-imx95-00.patch \
	file://0004-debug-ucm-imx95-dts-Add-lvds-stuff-in-the-main-file.patch \
	file://0005-debug-ucm-imx95-dts-Clean-up-the-main-file.patch \
	file://0006-debug-ucm-imx95-dts-Fix-lvds-panel-support.patch \
	file://0007-debug-ucm-imx95-dts-Prepare-for-bt-wifi.patch \
"
