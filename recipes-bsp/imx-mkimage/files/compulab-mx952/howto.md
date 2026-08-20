# Development

* Cross & Environment
```
export CROSS_COMPILE=/opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-
export SM_CROSS_COMPILE=${CROSS_COMPILE}
export OEI_CROSS_COMPILE=${CROSS_COMPILE}
export TOOLS=/opt/compulab/imx-oei
export ARCH=arm
sudo mkdir -p ${TOOLS}
sudo ln -sf dirname $(dirname ${SM_CROSS_COMPILE}) ${TOOLS}/
```

* imx-oei
```
make -j 32 board=mx952cpl DDR_CONFIG=lpddr5_timing_8g DEBUG=1 r=@@IMX_SOC_REV@@ oei=ddr
```

* imx-system-manager
```
make -j 32 V=y M=2 config=mx952cpl cfg && make -j 32 V=y M=2 config=mx952cpl
```

* imx-atf otee-os u-boot
Is not covered in this manual.

# Run it in ${DEPLOYDIR}/imx-boot-tools folder

* imx-boot all
```
make SOC=iMX952 REV=@@IMX_SOC_REV@@ OEI=YES LPDDR_TYPE=lpddr5 dtbs=ucm-imx952.dtb flash_all
```

* imx-boot arm Cortex-M7 under control of Cortex-A55 U-Boot/Linux
```
make SOC=iMX952 REV=@@IMX_SOC_REV@@ OEI=YES LPDDR_TYPE=lpddr5 dtbs=ucm-imx952.dtb flash_a55
```

* Boot Env for Cortex-M7 under Linux control
```
setenv boot_opt 'clk_ignore_unused pd_ignore_unused'
```

* Change the M7 default firmware used by imx-boot
```
./m7-set.sh
```
