FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}_${PV}:"

SRC_URI:append:compulab-mx95 = " \
    file://0001-compulab-Add-boards-mcimx95cpl.patch \
    file://0002-compulab-Apply-the-imx95-CompuLab-SOM-changes.patch \
    file://0003-compulab-Add-configs-mx95cpl.cfg.patch \
    file://0004-monitor_cmds-Improve-lm-command.patch \
"

SRC_URI:append:compulab-mx952 = " \
    file://0001-compulab-Add-boards-mcimx952cpl.patch \
    file://0002-compulab-Apply-the-imx952-CompuLab-SOM-changes.patch \
    file://0003-compulab-Add-configs-mx952cpl.cfg.patch \
    file://0004-compulab-imx952-monitor_cmds-Improve-lm-command.patch \
"
