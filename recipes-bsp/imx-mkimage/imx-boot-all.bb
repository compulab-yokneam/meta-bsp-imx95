SUMMARY = "CompuLab i.MX95 boot container matrix"
DESCRIPTION = "Build A0/B0 boot containers for all supported DDR types and capacities without multiconfig"
LICENSE = "GPL-2.0-or-later & GPL-2.0-only & BSD-3-Clause & Proprietary"
LIC_FILES_CHKSUM = " \
    file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
    file://../oei/LICENSE.txt;md5=b66f32a90f9577a5a3255c21d79bc619 \
    file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6 \
"

inherit deploy python3native kernel-arch

# Independent sources: normal u-boot-compulab/imx-oei work directories are
# never reconfigured or modified by this target. Keep these pins aligned with
# the corresponding BSP recipes when updating the bundle.
IMX_BOOT_ALL_UBOOT_SRCREV ?= "31e41b6fee026c0c57e5f187d03e5f1235604e34"
IMX_BOOT_ALL_OEI_SRCREV ?= "e9bce6f4f69dceaf3664b7e28eb4302004ee0361"
IMX_BOOT_ALL_MKIMAGE_SRCREV ?= "1b577853ae1afe1f26cdef27548da52fb424af48"
SRCREV_uboot = "${IMX_BOOT_ALL_UBOOT_SRCREV}"
SRCREV_oei = "${IMX_BOOT_ALL_OEI_SRCREV}"
SRCREV_mkimage = "${IMX_BOOT_ALL_MKIMAGE_SRCREV}"
SRCREV_FORMAT = "uboot_oei_mkimage"

FILESEXTRAPATHS:prepend := "${THISDIR}/../imx-oei/imx-oei:${THISDIR}/../u-boot/u-boot-compulab:"
SRC_URI = " \
    git://github.com/compulab-yokneam/u-boot-compulab;protocol=https;branch=u-boot-compulab_v2025.04;name=uboot;destsuffix=uboot \
    git://github.com/nxp-imx/imx-oei.git;protocol=https;branch=master;name=oei;destsuffix=oei \
    git://github.com/nxp-imx/imx-mkimage.git;protocol=https;branch=lf-6.18.20_2.0.0;name=mkimage;destsuffix=mkimage \
    file://0001-compulab-dram-Add-lpddr5-timing-options-for-4G-8G-an.patch;patchdir=../oei \
    file://0001-compulab-dram-Add-lpddr4-timing-options-for-4G.patch;patchdir=../oei \
    file://0002-compulab-dram-Add-lpddr4-timing-options-for-8G.patch;patchdir=../oei \
"
SRC_URI:append:mcm-imx95-sbc = " file://mcm-imx95.cfg file://mcm-imx95-sbc.cfg"

S = "${UNPACKDIR}/uboot"
B = "${WORKDIR}/build"

DEPENDS = " \
    bc-native bison-native dtc-native flex-native gnutls-native \
    openssl-native python3-setuptools-native swig-native xxd-native \
    gcc-arm-none-eabi-native \
"

IMX_BOOT_ALL_REVISIONS ?= "A0 B0"
IMX_BOOT_ALL_DDR_TYPES ?= "lpddr5 lpddr4x"
IMX_BOOT_ALL_LPDDR5_SIZES ?= "D4 D8 D16"
IMX_BOOT_ALL_LPDDR4X_SIZES ?= "D4 D8"
IMX_BOOT_ALL_TARGETS ?= "flash_all flash_lpboot_sm_a55"
IMX_BOOT_ALL_DDR_FW_VERSION ?= "v202409"

# The MCM machine reuses the UCM defconfig with board-specific fragments and
# does not define UBOOT_CONFIG_BASENAME. Follow the machine's SD selection.
IMX_BOOT_ALL_UBOOT_DEFCONFIG ?= "${@(d.getVarFlag('UBOOT_CONFIG', 'sd') or '').split(',')[0]}"
IMX_BOOT_ALL_UBOOT_FRAGMENTS ?= ""
IMX_BOOT_ALL_UBOOT_FRAGMENTS:mcm-imx95-sbc = " \
    ${UNPACKDIR}/mcm-imx95.cfg ${UNPACKDIR}/mcm-imx95-sbc.cfg \
"

# Shared platform firmware is built once by its normal recipes. DDR and ELE
# inputs are exported separately so both DDR types and both revisions are
# available regardless of the current MACHINE's DDR_TYPE/IMX_SOC_REV.
do_compile[depends] += " \
    imx-boot-firmware-files:do_deploy_boot_matrix \
    firmware-ele-imx:do_deploy_boot_matrix \
    imx-atf:do_deploy \
    optee-os:do_deploy \
    imx-system-manager:do_deploy \
    imx-m7-demos:do_deploy \
"
IMX_BOOT_ALL_INPUTS = "${DEPLOY_DIR_IMAGE}/imx-boot-all-inputs"
IMX_BOOT_ALL_ATF = "${DEPLOY_DIR_IMAGE}/bl31-${ATF_PLATFORM}.bin-optee"

python __anonymous() {
    if 'compulab-mx95' not in (d.getVar('MACHINEOVERRIDES') or '').split(':'):
        return
    variant = (d.getVar('IMXBOOT_VARIANT') or '').strip()
    if variant not in ('', 'mx95cpl', 'mx95cplrpmsg', 'rpmsg'):
        bb.fatal('imx-boot-all: IMXBOOT_VARIANT must be mx95cpl or mx95cplrpmsg '
                 '(empty selects mx95cpl; rpmsg is a legacy alias for mx95cplrpmsg)')
    if not d.getVar('IMX_BOOT_ALL_UBOOT_DEFCONFIG'):
        bb.fatal('imx-boot-all requires an SD U-Boot defconfig; set IMX_BOOT_ALL_UBOOT_DEFCONFIG')
    choices = {
        'IMX_BOOT_ALL_REVISIONS': {'A0', 'B0'},
        'IMX_BOOT_ALL_DDR_TYPES': {'lpddr5', 'lpddr4x'},
        'IMX_BOOT_ALL_LPDDR5_SIZES': {'D4', 'D8', 'D16'},
        'IMX_BOOT_ALL_LPDDR4X_SIZES': {'D4', 'D8'},
        'IMX_BOOT_ALL_TARGETS': {'flash_all', 'flash_lpboot_sm_a55'},
    }
    for variable, supported in choices.items():
        values = (d.getVar(variable) or '').split()
        if not values or len(values) != len(set(values)) or set(values) - supported:
            bb.fatal('%s must contain unique values from: %s' %
                     (variable, ' '.join(sorted(supported))))
    # Only the selected deploy task enters this build's dependency graph.
    # Separate task names give each variant its own sstate manifest, so stale
    # state cleanup for one configuration cannot delete the other one's files.
    sm_config = d.getVar('SYSTEM_MANAGER_CONFIG')
    if sm_config not in ('mx95cpl', 'mx95cplrpmsg'):
        bb.fatal('imx-boot-all: unsupported SYSTEM_MANAGER_CONFIG: %s' % sm_config)
    bb.build.addtask('do_deploy_' + sm_config, 'do_deploy', 'do_compile', d)
}

do_configure[noexec] = "1"
do_compile[cleandirs] = "${B}"

boot_matrix_copy() {
    [ -s "$1" ] || bbfatal "Missing boot matrix input: $1"
    install -m 0644 "$1" "$2"
}

boot_matrix_uboot() {
    dram="$1"
    ub="${B}/uboot/$dram"
    install -d "$ub"
    oe_runmake -C "${S}" O="$ub" \
        CROSS_COMPILE=${TARGET_PREFIX} \
        HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" \
        "${IMX_BOOT_ALL_UBOOT_DEFCONFIG}"
    if [ -n "${IMX_BOOT_ALL_UBOOT_FRAGMENTS}" ]; then
        "${S}/scripts/kconfig/merge_config.sh" -m -O "$ub" \
            "$ub/.config" ${IMX_BOOT_ALL_UBOOT_FRAGMENTS}
    fi
    for capacity in D4 D8 D16; do
        "${S}/scripts/config" --file "$ub/.config" --disable "DRAM_$capacity"
    done
    "${S}/scripts/config" --file "$ub/.config" --enable "DRAM_$dram"
    "${S}/scripts/config" --file "$ub/.config" \
        --set-str LOCALVERSION "-compulab-${CL_RELEASE}-$dram"
    oe_runmake -C "${S}" O="$ub" CROSS_COMPILE=${TARGET_PREFIX} \
        HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" olddefconfig
    grep -qx "CONFIG_DRAM_$dram=y" "$ub/.config" || \
        bbfatal "U-Boot did not select DRAM_$dram"
    oe_runmake -C "${S}" O="$ub" CROSS_COMPILE=${TARGET_PREFIX} \
        CC="${TARGET_PREFIX}gcc ${TOOLCHAIN_OPTIONS} ${DEBUG_PREFIX_MAP}" \
        HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" \
        STAGING_INCDIR="${STAGING_INCDIR_NATIVE}" \
        STAGING_LIBDIR="${STAGING_LIBDIR_NATIVE}" all
}

boot_matrix_variant() {
    revision="$1"
    dram="$2"
    ddr="$3"
    variant="$revision/$dram/$ddr"
    case "$ddr" in
        lpddr5) board=mx95lp5 ;;
        lpddr4x) board=mx95lp4x ;;
    esac
    case "$dram" in
        D4) timing="${ddr}_timing_4g" ;;
        D8) timing="${ddr}_timing_8g" ;;
        D16) timing="${ddr}_timing_16g" ;;
    esac

    bbnote "Building boot matrix variant: $variant"
    for kind in ddr tcm; do
        (
            cd "${UNPACKDIR}/oei"
            oe_runmake BUILD="${B}/oei/$variant" board="$board" \
                DDR_CONFIG="$timing" r="$revision" oei="$kind" \
                DEBUG=1 OEI_CROSS_COMPILE=arm-none-eabi- img
        )
    done

    # Each target gets a fresh mkimage tree: no generated container, padding,
    # quick-boot data or input links can leak between variants or targets.
    for target in ${IMX_BOOT_ALL_TARGETS}; do
        mk="${B}/mkimage/$variant/$target"
        install -d "$mk"
        cp -a "${UNPACKDIR}/mkimage/." "$mk/"
        stage="$mk/iMX95"
        boot_matrix_copy "${B}/uboot/$dram/u-boot.bin" "$stage/u-boot.bin"
        boot_matrix_copy "${B}/uboot/$dram/spl/u-boot-spl.bin" "$stage/u-boot-spl.bin"
        boot_matrix_copy "${IMX_BOOT_ALL_ATF}" "$stage/bl31.bin"
        boot_matrix_copy "${DEPLOY_DIR_IMAGE}/tee.bin" "$stage/tee.bin"
        boot_matrix_copy "${DEPLOY_DIR_IMAGE}/${SYSTEM_MANAGER_FIRMWARE_NAME}.bin" \
            "$stage/m33_image.bin"
        boot_matrix_copy "${DEPLOY_DIR_IMAGE}/mcore-demos/${M4_DEFAULT_IMAGE_MX95}" \
            "$stage/m7_image.bin"
        rev_lower=$(echo "$revision" | tr '[:upper:]' '[:lower:]')
        boot_matrix_copy "${IMX_BOOT_ALL_INPUTS}/ele/mx95$rev_lower-ahab-container.img" \
            "$stage/mx95$rev_lower-ahab-container.img"
        for firmware in imem dmem imem_qb dmem_qb; do
            name="${ddr}_${firmware}_${IMX_BOOT_ALL_DDR_FW_VERSION}.bin"
            boot_matrix_copy "${IMX_BOOT_ALL_INPUTS}/ddr/$name" "$stage/$name"
        done
        for kind in ddr tcm; do
            boot_matrix_copy "${B}/oei/$variant/$board/$kind/oei-m33-$kind.bin" \
                "$stage/oei-m33-$kind.bin"
        done
        (
            cd "$mk"
            oe_runmake CC="${BUILD_CC} ${BUILD_LDFLAGS}" \
                CFLAGS="${BUILD_CFLAGS}" SOC=iMX95 REV="$revision" \
                OEI=YES LPDDR_TYPE="$ddr" "$target"
        )
        output="${B}/output/$variant/$target"
        install -d "$output"
        boot_matrix_copy "$stage/flash.bin" "$output/flash.bin"
        cp "$output/flash.bin" "$output/flash.bin.tagged"
        stat -L -cUUUBURNXXOEUZX7+A-XY5601QQWWZ%sEND "$output/flash.bin" \
            >> "$output/flash.bin.tagged"
    done
}

do_compile() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS AS LD
    # U-Boot depends on capacity; DDR initialization and revision selection
    # live in OEI and mkimage. Build each capacity only once.
    for dram in D4 D8 D16; do
        needed=""
        for ddr in ${IMX_BOOT_ALL_DDR_TYPES}; do
            case "$ddr" in
                lpddr5) sizes="${IMX_BOOT_ALL_LPDDR5_SIZES}" ;;
                lpddr4x) sizes="${IMX_BOOT_ALL_LPDDR4X_SIZES}" ;;
            esac
            case " $sizes " in *" $dram "*) needed=yes ;; esac
        done
        [ -z "$needed" ] || boot_matrix_uboot "$dram"
    done
    for revision in ${IMX_BOOT_ALL_REVISIONS}; do
        for ddr in ${IMX_BOOT_ALL_DDR_TYPES}; do
            case "$ddr" in
                lpddr5) sizes="${IMX_BOOT_ALL_LPDDR5_SIZES}" ;;
                lpddr4x) sizes="${IMX_BOOT_ALL_LPDDR4X_SIZES}" ;;
            esac
            for dram in $sizes; do
                boot_matrix_variant "$revision" "$dram" "$ddr"
            done
        done
    done
}

do_install() {
    install -d "${D}/boot/${PN}/${SYSTEM_MANAGER_CONFIG}"
    cp -R "${B}/output/." "${D}/boot/${PN}/${SYSTEM_MANAGER_CONFIG}/"
}

# Keep the standard deploy task as the public entry point. Its own sstate
# manifest is empty; all payloads are owned by the variant-specific tasks.
do_deploy() {
    :
}
addtask deploy after do_compile before do_build

boot_matrix_deploy() {
    sm_config="$1"
    [ "$sm_config" = "${SYSTEM_MANAGER_CONFIG}" ] || \
        bbfatal "Select IMXBOOT_VARIANT=$sm_config before deploying this variant"
    destination="${WORKDIR}/deploy-${PN}-$sm_config/${PN}/$sm_config"
    install -d "$destination"
    cp -R "${B}/output/." "$destination/"
    (
        cd "$destination"
        find . -type f -name 'flash.bin*' -print0 | sort -z | \
            xargs -0 sha256sum > SHA256SUMS
    )
}

do_deploy_mx95cpl() {
    boot_matrix_deploy mx95cpl
}
do_deploy_mx95cplrpmsg() {
    boot_matrix_deploy mx95cplrpmsg
}
addtask deploy_mx95cpl after do_compile
addtask deploy_mx95cplrpmsg after do_compile

SSTATETASKS += "do_deploy_mx95cpl do_deploy_mx95cplrpmsg"
do_deploy_mx95cpl[dirs] = "${B}"
do_deploy_mx95cpl[cleandirs] = "${WORKDIR}/deploy-${PN}-mx95cpl"
do_deploy_mx95cpl[stamp-extra-info] = "${MACHINE_ARCH}"
do_deploy_mx95cpl[sstate-inputdirs] = "${WORKDIR}/deploy-${PN}-mx95cpl"
do_deploy_mx95cpl[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_deploy_mx95cplrpmsg[dirs] = "${B}"
do_deploy_mx95cplrpmsg[cleandirs] = "${WORKDIR}/deploy-${PN}-mx95cplrpmsg"
do_deploy_mx95cplrpmsg[stamp-extra-info] = "${MACHINE_ARCH}"
do_deploy_mx95cplrpmsg[sstate-inputdirs] = "${WORKDIR}/deploy-${PN}-mx95cplrpmsg"
do_deploy_mx95cplrpmsg[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"

python do_deploy_mx95cpl_setscene() {
    sstate_setscene(d)
}
python do_deploy_mx95cplrpmsg_setscene() {
    sstate_setscene(d)
}
addtask deploy_mx95cpl_setscene
addtask deploy_mx95cplrpmsg_setscene

FILES:${PN} = "/boot/${PN}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "^compulab-mx95$"
