FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-Add-mcimx95cpl-board-support.patch \
	file://0002-fsl_lpi2c-Prevent-the-SM-null-pointer-exception.patch \
	file://0003-HACK-Prevent-the-u-boot-hang-while-asking-the-temper.patch \
	file://0004-monitor_cmds-lm-Allow-set-default-lm-number.patch \
"

PATCHTOOL = "git"
