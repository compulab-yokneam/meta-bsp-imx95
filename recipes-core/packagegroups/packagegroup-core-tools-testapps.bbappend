# CompuLab images use NetworkManager, which conflicts with the ConnMan daemon
# pulled in by connman-client. Keep the remaining test applications.
RDEPENDS:${PN}:remove:compulab-mx95 = "connman-tools connman-tests connman-client"
RDEPENDS:${PN}:remove:compulab-mx952 = "connman-tools connman-tests connman-client"
