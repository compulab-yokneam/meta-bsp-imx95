FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Add-mcimx95cust-board.patch"

SYSTEM_MANAGER_CONFIG = "mx95cust"
