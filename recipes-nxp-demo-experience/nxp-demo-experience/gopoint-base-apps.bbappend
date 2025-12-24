# Copyright 2025 CompuLab
# Make it work with the define MACHINE
# TBD: Move it to a common layer
do_install:prepend() {
    sed -i "s/\(\"compatible.*\)\",/\1, ${MACHINE}\", /g" ${S}/demos.json
}
