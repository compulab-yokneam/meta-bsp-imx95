# Intro
* Supported Compulab Products<br>
[UCM-iMX95 - i.MX95 SMD System-on-Module](https://www.compulab.com/products/computer-on-modules/ucm-imx95-nxp-i-mx-95-som-system-on-module/)

* Preferred OS for build host is Ubuntu 22.04. It can be utilized with [Docker](https://github.com/compulab-yokneam/yocker)

# Configuring the build
 * Set a CompuLab machine:

   | Machine | Command Line |
   | --- | --- |
   |ucm-imx95|```export COMPULAB_MACHINE=ucm-imx95```|

## Setup Yocto environment
  * Download NXP and CompuLab source:
    ```
    bash <(curl -L https://raw.githubusercontent.com/compulab-yokneam/meta-bsp-imx95/refs/heads/walnascar-6.12.34-2.1.0/tools/run.me)
    ```
  * Issue this command to init Yocto build environment:
    ```
    MACHINE=${COMPULAB_MACHINE} source compulab-setup-env build-${COMPULAB_MACHINE}
    ```

## Pre-build customization (optional)
* Set a correct imx soc revision:<br>
The current relase supports three SOC revisions: **A0**, **A1** and **B0**.

   |NOTE|[Default revision is B0](https://github.com/nxp-imx/meta-imx/blob/walnascar-6.12.34-2.1.0/meta-imx-bsp/conf/machine/include/imx-base-extend.inc#L23)|
   | --- | --- |

   |Revision|``conf/local.conf`` string|
   |---|---|
   |A0| IMX_SOC_REV:mx95-generic-bsp = "A0"|
   |A1| IMX_SOC_REV:mx95-generic-bsp = "A0"|
   |B0| IMX_SOC_REV:mx95-generic-bsp = "B0"|

* M7 firmware:<br>
  i.MX95 allows booting the m7 core at the system start.<br>
  In order to achive that an M7 firmware has to be a part of the imx-boot image.<br>
  The [``M4_DEFAULT_IMAGE_MX95:mx95-generic-bsp``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar-6.12.34-2.1.0/conf/machine/compulab-imx95.inc#L34) variable specifies which firmware to use.

  In order to use another firmware add this line to the [``conf/local.conf``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar-6.12.34-2.1.0/templates/local.conf/local.conf.m7.append#L3):
  ```
  M4_DEFAULT_IMAGE_MX95:mx95-generic-bsp = "imx95-19x19-evk_m7_TCM_rpmsg_lite_str_echo_rtos.bin"
  ```
  Precompiled m7 firmware files can be found at ``${DEPLOYDIR}/mcore-demos``

* Set SM configuration:<br>
  The current relase provides two SM configurations: **mx95cpl** and **mx95cplrpmsg**.<br>

  |NOTE|Default SM configuration is ``mx95cpl``|
  |---|---|

  The systen controller configuration can be changed by setting a value to ``IMXBOOT_VARIANT`` variable in the [``conf/local.conf``](https://github.com/compulab-yokneam/meta-bsp-imx95/blob/walnascar-6.12.34-2.1.0/templates/local.conf/local.conf.soc-revision.append#L8):<br>

  |Variable|Value|Description|
  |---|---|---|
  |IMXBOOT_VARIANT|""|SM configuration ``mx95cpl`` is in use|
  |IMXBOOT_VARIANT|"rpmsg"|SM configuration ``mx95cplrpmsg`` is in use|
  In order to change the default IMXBOOT_VARIANT add this line to the ``conf/local.conf``:
  ```
  IMXBOOT_VARIANT = "rpmsg"
  ```
  Deatlis about SM and M7 can be found [here](https://github.com/compulab-yokneam/Documentation/blob/master/man/imx95-m7.md).

##  Building full rootfs image
* Build command:
  ```
  bitbake -k imx-image-full
  image_location=${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}/imx-image-full-${COMPULAB_MACHINE}*.wic.zst
  ```

## Building bootloader only (optional)
* Build command:
  ```
  bitbake -k imx-boot
  bootloader_location=${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}/imx-boot-tagged
  ```

## Deployment
### Bootable sd card method
* Host Machine command:
  ```
  sudo zstd -dc $image_location | sudo dd bs=1M status=progress of=/dev/sdX
  ```
* SoM procedur:
  * Power off
  * Insert the created sd-card
  * short alt. boot jumper
  * Power on

### UUU method
* Host Machine
  * Update bootloader and the rootfs:
    ```
    cd ${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}
    sudo uuu -v -bmap -b emmc_all imx-boot-tagged imx-image-full-${COMPULAB_MACHINE}.wic.zst
    ```
  * Update bootloader only:
    ```
    cd ${BUILDDIR}/tmp/deploy/images/${COMPULAB_MACHINE}
    sudo uuu -v -b emmc imx-boot-tagged
    ```

* SoM procedur:
  * Power off
  * Connect USB cable from host type A to SoM Serial Download microUSB
  * Short SDP boot jumper
  * Power on
