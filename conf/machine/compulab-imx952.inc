MACHINEOVERRIDES =. "mx952:compulab-mx952:"

require conf/machine/include/imx-base.inc
require conf/machine/include/arm/armv8-2a/tune-cortexa55.inc

MACHINE_FEATURES += "pci wifi bluetooth optee"
MACHINE_FEATURES:append:use-nxp-bsp = " crrm jailhouse nxpwifi-all-sdio nxpaw693-pcie xen"

IMX_DEFAULT_BOOTLOADER:use-nxp-bsp = "u-boot-compulab"
IMX_DEFAULT_BOOTLOADER:use-mainline-bsp = "u-boot-compulab"

LOADADDR = ""
UBOOT_SUFFIX = "bin"
UBOOT_MAKE_TARGET = ""

SPL_BINARY = "spl/u-boot-spl.bin"

UBOOT_CONFIG ??= "${@bb.utils.contains('COMBINED_FEATURES', 'crrm', 'crrm', 'sd', d)}"
UBOOT_CONFIG[sd] = "${UBOOT_CONFIG_BASENAME}_defconfig"
UBOOT_CONFIG[sd-ecc] = "${UBOOT_CONFIG_BASENAME}_defconfig"
UBOOT_CONFIG[crrm] = "${UBOOT_CONFIG_BASENAME}_xspi_crrm_defconfig"
UBOOT_CONFIG[xspi] = "${UBOOT_CONFIG_BASENAME}_xspi_defconfig"

IMXBOOT_TARGETS_BASENAME = "flash"

ATF_PLATFORM = "imx952"
OEI_CORE   = "m33"
OEI_SOC    = "mx952"
OEI_BOARD  = "mx952lp5-19"
DDR_TYPE   = "lpddr5"
DDR_FIRMWARE_NAME = " \
    lpddr5_dmem_v202409.bin \
    lpddr5_dmem_qb_v202409.bin \
    lpddr5_imem_v202409.bin \
    lpddr5_imem_qb_v202409.bin \
"

IMXBOOT_VARIANTS = "alt jailhouse netc rpmsg"

# Multiple system manager configs by IMXBOOT_VARIANT
SYSTEM_MANAGER_CONFIG = "${@bb.utils.contains('IMXBOOT_VARIANT','rpmsg','mx952cplrpmsg','mx952cpl', d)}"

# imx-boot (flash.bin) targets based on UBOOT_CONFIG and IMXBOOT_VARIANT
IMXBOOT_TARGETS_SD = " \
    ${@bb.utils.contains('IMXBOOT_VARIANT', 'alt',       '${IMXBOOT_TARGETS_BASENAME}_all', \
       bb.utils.contains('IMXBOOT_VARIANT', 'jailhouse', '${IMXBOOT_TARGETS_BASENAME}_jailhouse', \
       bb.utils.contains('IMXBOOT_VARIANT', 'netc',      '${IMXBOOT_TARGETS_BASENAME}_all', \
       bb.utils.contains('IMXBOOT_VARIANT', 'rpmsg',     '${IMXBOOT_TARGETS_BASENAME}_lpboot_sm_a55', \
                                                         '${IMXBOOT_TARGETS_BASENAME}_all ${IMXBOOT_TARGETS_BASENAME}_a55', d), d), d), d)} \
"
IMXBOOT_TARGETS = " \
    ${@bb.utils.contains('UBOOT_CONFIG', 'crrm',   '${IMXBOOT_TARGETS_BASENAME}_a55_xspi_crrm', \
       bb.utils.contains('UBOOT_CONFIG', 'sd-ecc', '${IMXBOOT_TARGETS_BASENAME}_all', \
       bb.utils.contains('UBOOT_CONFIG', 'xspi',   '${IMXBOOT_TARGETS_BASENAME}_a55_xspi', \
                                                   '${IMXBOOT_TARGETS_SD}', d), d), d)} \
"

M4_DEFAULT_IMAGE_MX952 = "${@bb.utils.contains('IMXBOOT_VARIANT', 'netc', 'imx952evk_m7_TCM_netc_share.bin', \
                                                                          'imx952evk_m7_TCM_power_mode_switch.bin', d)}"

IMX_BOOT_SOC_TARGET = "iMX952"
IMX_BOOT_SEEK = "32"

# We have to disable SERIAL_CONSOLE due to auto-serial-console
SERIAL_CONSOLES = "115200;ttyLP0"

IMX_DEFAULT_BSP = "nxp"

KERNEL_DEVICETREE:append = " \
    compulab/imx952-csi1-ap1302.dtbo \
    compulab/imx952-csi1-imx219.dtbo \
    compulab/imx952-csi1-imx477.dtbo \
    compulab/imx952-csi2-ap1302.dtbo \
    compulab/imx952-lvds.dtbo \
    compulab/imx952-rpmsg.dtbo \
    compulab/imx952-spidev.dtbo \
    compulab/imx952-wm8962.dtbo \
"

IMAGE_BOOT_FILES:append:imx-nxp-bsp = " \
    mcore-demos/imx952evk_m7_TCM_hello_world.bin \
    mcore-demos/imx952evk_m7_TCM_netc_share.bin \
    mcore-demos/imx952evk_m7_TCM_power_mode_switch.bin \
    mcore-demos/imx952evk_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.bin \
    mcore-demos/imx952evk_m7_TCM_rpmsg_lite_str_echo_rtos.bin \
    mcore-demos/imx952evk_m7_TCM_sai_low_power_audio.bin \
    ${@bb.utils.contains('COMBINED_FEATURES', 'xen', 'xen', '', d)} \
"

DRAM_CONF ?= "D8"

require include/compulab-default.inc
