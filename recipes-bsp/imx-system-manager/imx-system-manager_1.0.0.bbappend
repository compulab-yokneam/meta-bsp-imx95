FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Add-mcimx95cust-board.patch \
            file://0002-Fix-null-pionter-except.patch \
            "

SYSTEM_MANAGER_CONFIG = "mx95cust"
