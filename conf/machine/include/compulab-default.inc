#
# CompuLab default values
#

PREFERRED_PROVIDER_virtual/kernel:compulab-mx95 = "linux-compulab"
PREFERRED_PROVIDER_virtual/bootloader:compulab-mx95 = "u-boot-compulab"

PREFERRED_PROVIDER_virtual/kernel:compulab-mx952 = "linux-compulab"
PREFERRED_PROVIDER_virtual/bootloader:compulab-mx952 = "u-boot-compulab"

IMAGE_INSTALL:append = " \
	kernel-image \
	kernel-modules \
	kernel-devicetree \
"

PREFERRED_RROVIDER_u-boot-fw-utils = "libubootenv-bin"

DISTRO_FEATURES:remove = "sysvinit"
