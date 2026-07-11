FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}_${PV}:"

SRC_URI += " \
	file://0001-compulab-Add-boards-mcimx95cpl.patch \
	file://0002-compulab-Apply-the-imx95-CompuLab-SOM-changes.patch \
	file://0003-compulab-Add-configs-mx95cpl.cfg.patch \
	file://0004-monitor_cmds-Improve-lm-command.patch \
"
