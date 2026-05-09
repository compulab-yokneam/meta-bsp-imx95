DESCRIPTION = "Enable IMX477 Camera Module in neo-ipa-uguzzi for i.MX95"

SRC_IMX477 = "git://github.com/nxp-imx-support/imx-camera-sw-pack-source.git;protocol=https"
SRC_BRANCH = "LF6.12.20_2.0.0"

SRC_URI += " \
        ${SRC_IMX477};branch=${SRC_BRANCH};destsuffix=src_imx477;fsl-eula=true;name=imx477;subpath=imx95-camera-sw-pack-imx477\
"
SRCREV_FORMAT = "imx477"
SRCREV_imx477 = "b46692786eda78061e5d28fb4f4703af1ea8af90"

S_IMX477 = "${UNPACKDIR}/src_imx477/neo-ipa-uguzzi"

do_configure:prepend() {
    cp ${S_IMX477}/database_imx477_3840_2160.bin ${S}/data/
}
