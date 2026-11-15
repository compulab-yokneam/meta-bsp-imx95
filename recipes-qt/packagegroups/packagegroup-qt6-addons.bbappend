# Qt Device Utilities requires ConnMan; these machines use NetworkManager.
RDEPENDS:${PN}:remove:compulab-mx95 = "qtdeviceutilities"
RDEPENDS:${PN}:remove:compulab-mx952 = "qtdeviceutilities"
