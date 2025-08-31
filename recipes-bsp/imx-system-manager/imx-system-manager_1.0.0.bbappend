FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-compulab-Add-boards-mcimx95cpl.patch \
	file://0002-compulab-Apply-the-imx95-CompuLab-SOM-changes.patch \
	file://0003-compulab-Add-configs-mx95cpl.cfg.patch \
	file://0004-compulab-board-mcimx95cpl-Use-warm-reset-instead-of-.patch \
	file://0005-monitor_cmds-Improve-lm-command.patch \
	file://0006-ompulab-Add-configs-other-mx95cplrpmsg.cfg.patch \
"

PATCHTOOL = "git"
