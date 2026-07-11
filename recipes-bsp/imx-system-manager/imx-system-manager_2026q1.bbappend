FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}_${PV}:"

SRC_URI += " \
	file://0001-compulab-Add-boards-mcimx95cpl.patch \
	file://0002-compulab-Apply-the-imx95-CompuLab-SOM-changes.patch \
	file://0003-compulab-Add-configs-mx95cpl.cfg.patch \
	file://0004-compulab-board-mcimx95cpl-Use-warm-reset-instead-of-.patch \
	file://0005-monitor_cmds-Improve-lm-command.patch \
	file://0006-compulab-Add-configs-other-mx95cplrpmsg.cfg.patch \
	file://0007-comppulab-Set-BRD_SM_NAME-to-i.MX95-CompuLab-SOM.patch \
	file://0008-configs-mx95cplrpmsg.cfg-Apply-all-NXP-restrictions.patch \
"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=f2a70813bc08547f509361c08b718861"
SRCREV = "af1e37026c6ba19cdca98fd6e91494efd3e7b5ec"
