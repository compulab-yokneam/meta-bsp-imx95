# Build the CompuLab i.MX95 Boot Container Matrix

`imx-boot-all` builds the supported SoC revision, DRAM capacity, and DDR type
combinations in one BitBake invocation, without multiconfig or nested BitBake
commands:

```bash
cd /path/to/compulab-imx95-bsp
source compulab-setup-env build-ucm-imx95
bitbake imx-boot-all
```

See the [build-flow diagram](imx-boot-all-build-flow.md) for the recipe's source,
firmware, compilation, and deployment flow.

This is an explicit bundle target for machines using the `compulab-mx95`
override. The layer currently defines `ucm-imx95` and `mcm-imx95-sbc` in this
family. It does not replace `imx-boot`, change the current machine configuration,
or automatically add the bundle to images.

For MCM-iMX95, initialize the corresponding build environment instead:

```bash
MACHINE=mcm-imx95-sbc source compulab-setup-env build-mcm-imx95-sbc
bitbake imx-boot-all
```

Each invocation builds the matrix for its selected `MACHINE`, not all machines
at once. The U-Boot SD defconfig follows the machine configuration; MCM-iMX95
also receives its existing prompt and default device-tree fragments.

`ucm-imx952` uses the separate `compulab-mx952` SoC family and is not supported
by this i.MX95 matrix. It requires different U-Boot sources, OEI configuration,
ELE firmware, and imx-mkimage SoC selection.

## Default Matrix

| SoC revisions | DDR type | DRAM capacities |
|---|---|---|
| A0, B0 | LPDDR5 | D4, D8, D16 |
| A0, B0 | LPDDR4X | D4, D8 |

There are ten hardware combinations. The recipe builds two boot targets per
combination:

- `flash_all`: includes the configured Cortex-M7 firmware and starts M7 at boot.
- `flash_lpboot_sm_a55`: leaves M7 under U-Boot/Linux control.

The defaults therefore produce 20 boot containers, each with untagged
`flash.bin` and UUU-tagged `flash.bin.tagged` forms.

LPDDR4X D16 is excluded because the current CompuLab OEI integration has no
16 GiB LPDDR4X timing configuration. A generated container is not evidence of
hardware qualification: boot and memory tests are required for each populated
board configuration, especially A0 variants.

## How It Works

The recipe uses its own pinned U-Boot, OEI, and imx-mkimage source checkouts:

1. Build U-Boot and SPL once for each requested capacity, selecting the matching
   `CONFIG_DRAM_D4`, `CONFIG_DRAM_D8`, or `CONFIG_DRAM_D16` option after applying
   the selected machine's U-Boot configuration fragments.
2. Build OEI DDR and TCM firmware separately for each SoC revision, DDR type,
   and capacity. Apply the existing CompuLab LPDDR5 and LPDDR4X timing patches.
3. For each boot target, copy a fresh imx-mkimage tree and stage the selected
   U-Boot, OEI, DDR firmware, and revision-specific ELE container.
4. Assemble with `SOC=iMX95`, the requested `REV`, `OEI=YES`, and the requested
   `LPDDR_TYPE`.
5. Install and deploy the complete bundle with a checksum file.

Arm Trusted Firmware, OP-TEE, System Manager, and M7 demo firmware come from
their normal recipes and are shared across the matrix. The selected System
Manager configuration and M7 image follow the current machine/build settings;
this target does not enumerate additional System Manager or M7 variants.

Two explicit firmware export tasks provide both ELE revisions and both DDR
types regardless of the build directory's default revision or DDR type. These
tasks use separate sstate-managed deployment directories. They are dependencies
of `imx-boot-all` and do not run as part of normal firmware builds.

Each build directory is private to this recipe. Existing `imx-boot` artifacts,
normal U-Boot/OEI source trees, and default image boot links are not replaced.

## Output

Deployed files are under:

```text
tmp/deploy/images/${MACHINE}/imx-boot-all/
```

For example, a UCM-iMX95 build produces:

```text
tmp/deploy/images/ucm-imx95/imx-boot-all/
├── SHA256SUMS
├── A0/
│   ├── D4/
│   │   ├── lpddr5/
│   │   │   ├── flash_all/
│   │   │   │   ├── flash.bin
│   │   │   │   └── flash.bin.tagged
│   │   │   └── flash_lpboot_sm_a55/
│   │   │       ├── flash.bin
│   │   │       └── flash.bin.tagged
│   │   └── lpddr4x/...
│   ├── D8/...
│   └── D16/lpddr5/...
└── B0/...
```

Verify the deployed checksums with:

```bash
cd tmp/deploy/images/ucm-imx95/imx-boot-all
sha256sum -c SHA256SUMS
```

The recipe also creates an `imx-boot-all` package containing the boot
containers under `/boot/imx-boot-all/`. In a DEB-based build its package is
available in `tmp/deploy/deb/` under the machine package architecture.

## Build a Subset

The following settings in `conf/local.conf` restrict this recipe only:

```bitbake
IMX_BOOT_ALL_REVISIONS = "B0"
IMX_BOOT_ALL_DDR_TYPES = "lpddr5"
IMX_BOOT_ALL_LPDDR5_SIZES = "D8"
IMX_BOOT_ALL_TARGETS = "flash_lpboot_sm_a55"
```

Available settings and defaults:

| Variable | Default |
|---|---|
| `IMX_BOOT_ALL_REVISIONS` | `A0 B0` |
| `IMX_BOOT_ALL_DDR_TYPES` | `lpddr5 lpddr4x` |
| `IMX_BOOT_ALL_LPDDR5_SIZES` | `D4 D8 D16` |
| `IMX_BOOT_ALL_LPDDR4X_SIZES` | `D4 D8` |
| `IMX_BOOT_ALL_TARGETS` | `flash_all flash_lpboot_sm_a55` |

Requested values must be supported, nonempty, and unique. Requests for LPDDR4X
D16 fail during parsing rather than silently substituting another timing file.

## Maintenance

The bundle pins U-Boot 2025.04, OEI, and imx-mkimage independently of the normal
recipes. Update `IMX_BOOT_ALL_UBOOT_SRCREV`, `IMX_BOOT_ALL_OEI_SRCREV`, and
`IMX_BOOT_ALL_MKIMAGE_SRCREV` when updating this BSP. Verify that the existing
timing patches and shared platform firmware remain compatible with those
sources. This target does not consume edits in a normal recipe's devtool
workspace automatically.
