MACHINEOVERRIDES =. "mx95:compulab-mx95:"

PREFERRED_PROVIDER_virtual/kernel:compulab-mx95 = "linux-compulab"
PREFERRED_PROVIDER_virtual/bootloader:compulab-mx95 = "u-boot-compulab"
PREFERRED_PROVIDER_linux-imx-mfgtool:compulab-mx95 = "linux-compulab-mfgtool"
PREFERRED_PROVIDER_linux-compulab-mfgtool:compulab-mx95 = "linux-compulab-mfgtool"

IMAGE_INSTALL:append = " \
	kernel-image \
	kernel-modules \
	kernel-devicetree \
"

PREFERRED_RROVIDER_u-boot-fw-utils = "libubootenv-bin"
