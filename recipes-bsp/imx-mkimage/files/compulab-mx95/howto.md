# Development

* Cross & Environment
```
export CROSS_COMPILE=/opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-
export SM_CROSS_COMPILE=${CROSS_COMPILE}
export OEI_CROSS_COMPILE=${CROSS_COMPILE}
export TOOLS=/opt/compulab/imx-oei
export ARCH=arm
sudo mkdir -p ${TOOLS}
sudo ln -sfn "$(dirname "$(dirname "${SM_CROSS_COMPILE}")")" "${TOOLS}/"
```

* imx-oei
```
make -j 32 board=mx95lp5 DEBUG=1 DDR_CONFIG=lpddr5_timing r=@@IMX_SOC_REV@@ oei=ddr
make -j 32 board=mx95lp5 DEBUG=1 DDR_CONFIG=lpddr5_timing r=@@IMX_SOC_REV@@ oei=tcm
```

* imx-system-manager
```
make -j 32 V=y M=2 config=mx95cpl cfg && make -j 32 V=y M=2 config=mx95cpl
```

* imx-atf otee-os u-boot
Is not covered in this manual.

# UCM-iMX95 boot images and Cortex-M7 firmware

## Serial consoles

Use 115200 baud, 8 data bits, no parity, one stop bit, and no flow control.

| Core | Debug UART | Connector |
| --- | --- | --- |
| Cortex-A55 (U-Boot/Linux) | LPUART1 | P3 |
| Cortex-M33 (System Manager) | LPUART2 | P19: pin 2 RX, pin 4 TX, pin 8 GND |
| Cortex-M7 | LPUART3 | P20: pin 2 RX, pin 4 TX, pin 8 GND |

Connect the adapter TX signal to the board RX signal and the adapter RX signal
to the board TX signal. Connect GND; do not connect the adapter supply pin.

## Enter the boot-tools directory

The `imx-boot-tools` directory contains the artifacts required to rebuild
`flash.bin` without rebuilding the complete Yocto image.

Run the following commands directly in the deployed tools directory:

```bash
cd <build-dir>/tmp/deploy/images/ucm-imx95/imx-boot-tools
```

## Select the M7 firmware

The default `m7_image.bin` link selects the firmware configured by the Yocto
machine. To select another TCM-linked demo, run:

```bash
./m7-set.sh
```

The selected firmware is copied into `imx-boot-tools` and
`m7_image.bin` is updated to point to it.

## Build boot images

`flash_all` embeds the selected M7 firmware and starts the M7 during system
boot. The initial `clean` removes images left by an earlier invocation:

```bash
make SOC=iMX95 REV=@@IMX_SOC_REV@@ OEI=YES LPDDR_TYPE=@@DDR_TYPE@@ clean
make SOC=iMX95 REV=@@IMX_SOC_REV@@ OEI=YES LPDDR_TYPE=@@DDR_TYPE@@ flash_all
mv flash.bin flash-ucm-imx95-m7-autostart.bin
```

`flash_a55` omits the M7 firmware and leaves the M7 under U-Boot or Linux
control:

```bash
make SOC=iMX95 REV=@@IMX_SOC_REV@@ OEI=YES LPDDR_TYPE=@@DDR_TYPE@@ flash_a55
mv flash.bin flash-ucm-imx95-a55-controlled-m7.bin
```

## Load and start M7 firmware from U-Boot

Boot with the `flash_a55` image. Copy a TCM-linked `*m7_TCM*.bin` firmware file
to the FAT boot partition, stop at the U-Boot prompt, and run:

```text
=> prepaux 1
=> load mmc ${mmcdev}:${mmcpart} ${loadaddr} <m7-firmware>.bin
=> cp.b ${loadaddr} 0x203c0000 ${filesize}
=> dcache flush
=> bootaux 0 1
```

Here `0x203c0000` is the Cortex-A55-visible M7 TCM boot address, `0` is the
firmware entry address in the M7 address view, and core ID `1` selects the M7.
The firmware must be linked for M7 TCM and must fit in the 512 KiB TCM window.
Its output appears on LPUART3 at P20.

If the M7 is already running, stop it before loading another image:

```text
=> stopaux 1
```

An M7 embedded by `flash_all` is already started before U-Boot. Use
`flash_a55` when U-Boot must load and start the firmware.

## Preserve M7 resources when booting Linux

When an M7 application remains running while Linux boots, append the resource
retention arguments without removing existing options such as
`fbcon=nodefer`:

```text
=> setenv boot_opt "${boot_opt} clk_ignore_unused pd_ignore_unused"
=> saveenv
```

Omit `saveenv` if the setting is required for only the current boot.
