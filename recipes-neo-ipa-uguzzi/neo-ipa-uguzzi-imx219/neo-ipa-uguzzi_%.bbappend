DESCRIPTION = "Enable IMX219 Camera Module in neo-ipa-uguzzi for i.MX95"

SRC_IMX219 = "git://github.com/nxp-imx-support/imx-camera-sw-pack-source.git;protocol=https"
SRC_BRANCH = "LF6.12.20_2.0.0"

SRC_URI += " \
        ${SRC_IMX219};branch=${SRC_BRANCH};destsuffix=src_imx219;fsl-eula=true;name=imx219;subpath=imx95-camera-sw-pack-imx219\
"
SRCREV_FORMAT = "imx219"
SRCREV_imx219 = "b46692786eda78061e5d28fb4f4703af1ea8af90"

S_IMX219 = "${UNPACKDIR}/src_imx219/neo-ipa-uguzzi"

do_configure:prepend() {
    cp ${S_IMX219}/database_imx219_3280_2464.bin ${S}/data/
    cp ${S_IMX219}/database_imx219_1920_1080.bin ${S}/data/
}
