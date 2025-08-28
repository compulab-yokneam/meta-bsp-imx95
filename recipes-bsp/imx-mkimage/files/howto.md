# Development

* Cross & Environment
```
export SM_CROSS_COMPILE=/opt/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-
export OEI_CROSS_COMPILE=${SM_CROSS_COMPILE}
export TOOLS=/opt/imx-oei
export ARCH=arm
sudo mkdir -p ${TOOLS}
sudo ln -sf dirname $(dirname ${SM_CROSS_COMPILE}) ${TOOLS}/
```

* imx-oei
```
make -j 32 board=mx95lp5 DEBUG=1 DDR_CONFIG=lpddr5_timing r=B0 oei=ddr
make -j 32 board=mx95lp5 DEBUG=1 DDR_CONFIG=lpddr5_timing r=B0 oei=tcm
```

* imx-system-manager
```
make -j 32 V=y M=2 config=mx95cpl cfg && make -j 32 V=y M=2 config=mx95cpl
```

* imx-atf otee-os u-boot
Is not covered in this manual.

# Run it in ${DEPLOYDIR}/imx-boot-tools folder

* imx-boot all
```
make SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr5 flash_all
```

* imx-boot arm Cortex-M7 under control of Cortex-A55 U-Boot/Linux
```
make SOC=iMX95 REV=B0 OEI=YES LPDDR_TYPE=lpddr5 flash_lpboot_sm_a55
```

* Boot Env for Cortex-M7 under Linux control
```
setenv boot_opt 'clk_ignore_unused pd_ignore_unused'
```

* Change the M7 default firmware used by imx-boot
```
./m7-set.sh
```
