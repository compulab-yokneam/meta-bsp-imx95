# Export both DDR types only when explicitly requested by imx-boot-all.
BOOT_MATRIX_DDR_DIR = "${WORKDIR}/boot-matrix-ddr"
do_deploy_boot_matrix[cleandirs] = "${BOOT_MATRIX_DDR_DIR}"
do_deploy_boot_matrix[stamp-extra-info] = "${MACHINE_ARCH}"
do_deploy_boot_matrix() {
    for ddr in lpddr5 lpddr4x; do
        for kind in imem dmem imem_qb dmem_qb; do
            install -m 0644 "${S}/firmware/ddr/synopsys/${ddr}_${kind}_v202409.bin" \
                "${BOOT_MATRIX_DDR_DIR}/"
        done
    done
}
addtask deploy_boot_matrix after do_unpack

SSTATETASKS += "do_deploy_boot_matrix"
do_deploy_boot_matrix[sstate-inputdirs] = "${BOOT_MATRIX_DDR_DIR}"
do_deploy_boot_matrix[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}/imx-boot-all-inputs/ddr"
python do_deploy_boot_matrix_setscene() {
    sstate_setscene(d)
}
addtask deploy_boot_matrix_setscene
