do_install:append() {
	printf "\n[launcher]\nicon=/usr/share/icons/hicolor/24x24/apps/chromium.png\npath=/usr/bin/chromium --no-sandbox\n" >> ${D}${sysconfdir}/xdg/weston/weston.ini
}

