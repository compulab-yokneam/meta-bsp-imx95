# Disclaimer                                                                                                                                                                                                                                                                    

| !IMPORTANT! | This branch is not a release |
|---|---|

## Supported Compulab Products
[UCM-iMX95 - i.MX95 SMD System-on-Module](https://www.compulab.com/products/computer-on-modules/ucm-imx95-nxp-i-mx-95-som-system-on-module/)

**Preferred OS for build host is Ubuntu 22.04. It can be utilized with Docker: https://github.com/compulab-yokneam/yocker**
## Initialize repo manifests
* NXP:
```
mkdir compulab-nxp-bsp && cd compulab-nxp-bsp
repo init -u https://github.com/nxp-imx/imx-manifest.git -b imx-linux-scarthgap -m imx-6.6.52-2.2.0.xml
```
* CompuLab:
```
mkdir -p .repo/local_manifests
wget --directory-prefix .repo/local_manifests https://raw.githubusercontent.com/compulab-yokneam/meta-bsp-imx95/scarthgap-6.6.52-EVAL-UCM-iMX95-2.0/scripts/meta-bsp-imx95.xml
repo sync
```
## Setup Yocto build environment
* Set a machine that matches your SoM:
```
export MACHINE=ucm-imx95
```
* Initialize the environment:
```
source compulab-setup-env build-${MACHINE}
```
##  Building full rootfs image:
* Build command
```
bitbake -k imx-image-full
image_location=${BUILDDIR}/tmp/deploy/images/${MACHINE}/imx-image-full-${MACHINE}*.wic.zst
```
## Building bootloader only (optional):
* Build command
```
bitbake -k imx-boot
bootloader_location=${BUILDDIR}/tmp/deploy/images/${MACHINE}/imx-boot-tagged
```
## Deployment
### Bootable sd card method
#### Host Machine ####
```
sudo zstd -dc $image_location | sudo dd bs=1M status=progress of=/dev/sdX
```
#### SoM ####
* Power off
* Insert the created sd-card
* short alt. boot jumper
* Power on
### UUU method
#### Host Machine ####
* Update bootloader and the rootfs:
```
cd ${BUILDDIR}/tmp/deploy/images/${MACHINE}
sudo uuu -v -b emmc_all imx-boot-tagged imx-image-full-${MACHINE}.wic.zst
```
* Update bootloader only:
```
cd ${BUILDDIR}/tmp/deploy/images/${MACHINE}
sudo uuu -v -b emmc imx-boot-tagged
```

#### SoM ####
* Power off
* Connect USB cable from host type A to SoM Serial Download microUSB
* Short SDP boot jumper
* Power on
