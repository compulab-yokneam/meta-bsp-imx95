FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DESCRIPTION = "Enable IMX219 and IMX477 Camera Module in neo-ipa-uguzzi for i.MX95"

PATCHTOOL = "git"

SRC_URI:append = " \
	file://0001-neo-ipa-uguzzi-compulab-update.patch \
"
