MACHINEOVERRIDES =. "mx95:compulab-mx95:"

require conf/machine/include/imx-base.inc
require conf/machine/include/arm/armv8-2a/tune-cortexa55.inc

MACHINE_FEATURES += "pci wifi bluetooth optee"
MACHINE_FEATURES:append:use-nxp-bsp = " nxpwifi-all-pcie nxpwifi-all-sdio jailhouse dpdk xen"

IMX_DEFAULT_BOOTLOADER:use-nxp-bsp = "u-boot-compulab"
IMX_DEFAULT_BOOTLOADER:use-mainline-bsp = "u-boot-compulab"

LOADADDR = ""
UBOOT_SUFFIX = "bin"
UBOOT_MAKE_TARGET = ""

SPL_BINARY = "spl/u-boot-spl.bin"

IMXBOOT_TARGETS_BASENAME = "flash"

ATF_PLATFORM = "imx95"
OEI_CONFIGS = "ddr tcm"
OEI_CORE   = "m33"
OEI_SOC    = "mx95"
OEI_BOARD  = "mx95lp5"
DDR_TYPE   = "lpddr5"

DDR_FIRMWARE_NAME = " \
    lpddr5_dmem_v202311.bin \
    lpddr5_dmem_qb_v202311.bin \
    lpddr5_imem_v202311.bin \
    lpddr5_imem_qb_v202311.bin \
"

M4_DEFAULT_IMAGE_MX95 = "imx95-19x19-evk_m7_TCM_power_mode_switch_rtos_imx95_sm_cm7.bin"

SYSTEM_MANAGER_CONFIG = "mx95cust"

IMXBOOT_TARGETS = "${IMXBOOT_TARGETS_BASENAME}_all ${IMXBOOT_TARGETS_BASENAME}_a55"

IMX_BOOT_SOC_TARGET = "iMX95"
IMX_BOOT_SEEK = "32"

SERIAL_CONSOLES = "115200;ttyLP0"

PREFERRED_PROVIDER_virtual/kernel:compulab-mx95 = "linux-compulab"
PREFERRED_PROVIDER_virtual/bootloader:compulab-mx95 = "u-boot-compulab"

IMAGE_INSTALL:append = " \
	kernel-image \
	kernel-modules \
	kernel-devicetree \
"

PREFERRED_RROVIDER_u-boot-fw-utils = "libubootenv-bin"

DISTRO_FEATURES:remove = "sysvinit"

IMX_DEFAULT_BSP = "nxp"
