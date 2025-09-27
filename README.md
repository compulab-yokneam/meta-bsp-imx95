# Disclaimer                                                                                                                                                                                                                                                                    
| !IMPORTANT! | This branch is not a release |
|---|---|

# Intro
* Supported Compulab Products<br>
[UCM-iMX95 - i.MX95 SMD System-on-Module](https://www.compulab.com/products/computer-on-modules/ucm-imx95-nxp-i-mx-95-som-system-on-module/)

* Preferred OS for build host is Ubuntu 22.04. It can be utilized with [Docker](https://github.com/compulab-yokneam/yocker)


## Initialize repo manifests
* NXP:
```
mkdir compulab-nxp-bsp && cd compulab-nxp-bsp
repo init -u https://github.com/nxp-imx/imx-manifest.git -b imx-linux-walnascar -m imx-6.12.34-2.1.0.xml
```
* CompuLab:
```
mkdir -p .repo/local_manifests
wget --directory-prefix .repo/local_manifests https://raw.githubusercontent.com/compulab-yokneam/meta-bsp-imx95/walnascar/scripts/meta-bsp-imx95.xml
repo sync
```
## Setup Yocto build environment
* Set a machine that matches your SoM:
```
export COMPULAB_MACHINE=ucm-imx95
```
* Initialize the environment:
```
export MACHINE=${COMPULAB_MACHINE} source compulab-setup-env build-${COMPULAB_MACHINE}
```
* Set a correct imx soc revision (mandatory):

The current relase supports three SOC revisions: **A0**, **A1** and **B0**.
|NOTE|[Default revision is B0](https://github.com/nxp-imx/meta-imx/blob/walnascar-6.12.34-2.1.0/meta-imx-bsp/conf/machine/include/imx-base-extend.inc#L23)|
|---|---|

|Revision|``conf/local.conf`` string|
|---|---|
|A0| IMX_SOC_REV:mx95-generic-bsp = "A0"|
|A1| IMX_SOC_REV:mx95-generic-bsp = "A0"|
|B0| IMX_SOC_REV:mx95-generic-bsp = "B0"|

* M7 firmware (optional)
 
i.MX95 allows booting the m7 core at the system start.<br>
In order to achive that an M7 firmware has to be a part of the imx-boot image.<br>
The [``M4_DEFAULT_IMAGE_MX95:mx95-generic-bsp``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar/conf/machine/compulab-imx95.inc#L34) variable specifies which firmware to use.

In order to use another firmware add this line to the [``conf/local.conf``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar/templates/local.conf/local.conf.m7.append#L3):
```
M4_DEFAULT_IMAGE_MX95:mx95-generic-bsp = "imx95-19x19-evk_m7_TCM_rpmsg_lite_str_echo_rtos.bin"
```
Precompiled m7 firmware files can be found at ``${DEPLOYDIR}/mcore-demos``

* Set SM configuration

The current relase provides two SM configurations: **mx95cpl** and **mx95cplrpmsg**.<br>

|NOTE|Default SM configuration is ``mx95cpl``|
|---|---|

The systen controller configuration can be chabged by setting a value to ``IMXBOOT_VARIANT`` variable in the [``conf/local.conf``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar/templates/local.conf/local.conf.soc-revision.append#L8):<br>

|Variable|Value|Description|
|---|---|---|
|IMXBOOT_VARIANT|""|SM configuration ``mx95cpl`` is in use|
|IMXBOOT_VARIANT|"rpmsg"|SM configuration ``mx95cplrpmsg`` is in use|

In order to change the default IMXBOOT_VARIANT add this line to the ``conf/local.conf``:
```
IMXBOOT_VARIANT = "rpmsg"
```

Deatlis about SM and M7 can be found [here](https://github.com/compulab-yokneam/Documentation/blob/master/man/imx95-m7.md).

##  Building full rootfs image:
* Build command
```
bitbake -k imx-image-full
image_location=${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}/imx-image-full-${COMPULAB_MACHINE}*.wic.zst
```
## Building bootloader only (optional):
* Build command
```
bitbake -k imx-boot
bootloader_location=${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}/imx-boot-tagged
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
cd ${BUILDDIR}/tmp/deploy/images/${XOMPULAB_MACHINE}
sudo uuu -v -b emmc_all imx-boot-tagged imx-image-full-${COMPULAB_MACHINE}.wic.zst
```
* Update bootloader only:
```
cd ${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}
sudo uuu -v -b emmc imx-boot-tagged
```

#### SoM ####
* Power off
* Connect USB cable from host type A to SoM Serial Download microUSB
* Short SDP boot jumper
* Power on
