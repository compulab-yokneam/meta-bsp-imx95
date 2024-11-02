FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-remove-lcdif.patch \
            file://0002-Update-defconfig.patch \
            file://0003-mach-imx-Turn-the-imx_get_mac_from_fuse-into-a-weak.patch \
            file://0004-Add-compulab-baoards.patch \
            file://0005-nxp-video-imx_lcdifv3-CompuLab-update.patch \
            file://0006-imx_lcdifv3-Disable-display_enable-call.patch \
            file://0007-compulab-arch-arm-dts-Makefile.patch \
            file://0008-compulab-arch-arm-mach-imx-imx8m-clock_imx8mm.c.patch \
            file://0009-compulab-arch-arm-mach-imx-imx8m-Kconfig.patch \
            file://0010-imx8m-Disable-fixup_thermal_trips.patch \
            file://0011-efi-Disable-efi_net_register.patch \
            file://0012-compulab-arch-arm-include-asm-arch-imx8m-imx8mm_pins.patch \
            file://0013-compulab-Add-imx93-family.patch \
            file://0014-driver-pca9555-20-add-delay-to-eliminate-Error-of-re.patch \
            file://0015-drivers-video-Add-VIDEO_LCD_STARTEK_ILI9881C.patch \
            file://0016-ucm-imx93-2024.04-patch.patch \
            file://0001-compulab-Add-ucm-imx95-board-files.patch \
            file://0002-compulab-Enable-ucm-imx95-board-config.patch \
            file://0003-compulab-Update-ucm-imx95-board-files.patch \
            file://0006-ucm-imx95-board-Set-correct-phy-reset-gpios.patch file://0007-ucm-imx95-dts-Enable-boath-enetc-ifaces.patch file://0005-ucm-imx95-config-Set-env-offset-to-the-end-of-the-em.patch file://0004-ucm-imx95-env-Add-autoload-off.patch \
            "
