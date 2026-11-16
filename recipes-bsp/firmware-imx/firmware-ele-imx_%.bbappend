# An explicit imx-boot-all dependency only: normal firmware deployment stays
# revision-specific. Export both signed containers through a separate sstate
# task instead of writing into another recipe's work directory.
BOOT_MATRIX_ELE_DIR = "${WORKDIR}/boot-matrix-ele"
do_deploy_boot_matrix[cleandirs] = "${BOOT_MATRIX_ELE_DIR}"
do_deploy_boot_matrix[stamp-extra-info] = "${MACHINE_ARCH}"
do_deploy_boot_matrix() {
    for revision in a0 b0; do
        install -m 0644 "${S}/mx95$revision-ahab-container.img" \
            "${BOOT_MATRIX_ELE_DIR}/"
    done
}
addtask deploy_boot_matrix after do_unpack

SSTATETASKS += "do_deploy_boot_matrix"
do_deploy_boot_matrix[sstate-inputdirs] = "${BOOT_MATRIX_ELE_DIR}"
do_deploy_boot_matrix[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}/imx-boot-all-inputs/ele"
python do_deploy_boot_matrix_setscene() {
    sstate_setscene(d)
}
addtask deploy_boot_matrix_setscene
