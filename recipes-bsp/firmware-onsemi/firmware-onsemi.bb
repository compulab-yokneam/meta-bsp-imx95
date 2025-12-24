LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

SRC_URI = "git://github.com/ONSemiconductor/ap1302_binaries.git;protocol=https;branch=main"

# Modify these as desired
PV = "1.0+git"
SRCREV = "1742d72c7860a746d24ea1f4460767195f19da39"

S = "${WORKDIR}/git"

do_install () {
	install -d ${D}${base_libdir}/firmware/onsemi

	install -m 0644 ${S}/NXP_i.MX93/ap1302_60fps_ar0144_27M_2Lane_awb_tuning.bin ${D}${base_libdir}/firmware/onsemi/ap1302_ar0144_single_fw.bin
	install -m 0644 ${S}/NXP_i.MX93/ap1302_ar1355_rgb888_1080p30_4lane.bin       ${D}${base_libdir}/firmware/onsemi/ap1302_ar1355_rgb888_single_fw.bin
	install -m 0644 ${S}/NXP_i.MX93/ap1302_ar1355_yuv422_1080p30_4lane_48MHz.bin ${D}${base_libdir}/firmware/onsemi/ap1302_ar1355_yuv422_single_fw.bin

	ln -s onsemi/ap1302_ar0144_single_fw.bin        ${D}${base_libdir}/firmware/
	ln -s onsemi/ap1302_ar1355_rgb888_single_fw.bin ${D}${base_libdir}/firmware/
	ln -s onsemi/p1302_ar1355_yuv422_single_fw.bin ${D}${base_libdir}/firmware/

}

FILES:${PN} += "${base_libdir}/firmware"
PACKAGE_ARCH = "${MACHINE_ARCH}"
