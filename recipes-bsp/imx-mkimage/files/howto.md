* imx-oei
```
make -j 32 board=mx95lp5 DEBUG=1 OEI_CROSS_COMPILE=arm-none-eabi- DDR_CONFIG=lpddr5_timing oei=ddr
make -j 32 board=mx95lp5 DEBUG=1 OEI_CROSS_COMPILE=arm-none-eabi- DDR_CONFIG=lpddr5_timing oei=tcm
```

* imxsystem-manager
```
make -j 23 V=y SM_CROSS_COMPILE=arm-none-eabi- M=2 config=mx95cpl clean
make -j 23 V=y SM_CROSS_COMPILE=arm-none-eabi- M=2 config=mx95cpl cfg
make -j 32 V=y SM_CROSS_COMPILE=arm-none-eabi- M=2 config=mx95cpl
```

* imx-boot all
```
make SOC=iMX95 REV=A0 OEI=YES LPDDR_TYPE=lpddr5 flash_all
```

* imx-boot w/out m7
```
make SOC=iMX95 REV=A0 OEI=YES LPDDR_TYPE=lpddr5 flash_all_no_m7
```
