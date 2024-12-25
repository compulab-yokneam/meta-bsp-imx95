# Kernel Build Manual

## External Build

### Prerequisites
It is up to developers to prepare the host machine; it requires:

* [Setup Cross Compiler](https://github.com/compulab-yokneam/meta-bsp-imx8mp/blob/kirkstone/Documentation/toolchain.md#linaro-toolchain-how-to)

### CompuLab Linux Kernel setup

* WorkDir:
```
mkdir -p compulab-kernel/linux-compulab-build && cd compulab-kernel
```

* Set a machine:
```
export MACHINE=ucm-imx95
```

* Clone the source code:
```
git clone -b linux-compulab_v6.6.36 https://github.com/compulab-yokneam/linux-compulab.git
cd linux-compulab
```

### Compile the Kernel

* Apply the default CompuLab config:
```
make compulab-mx95_defconfig compulab.config
```

* Change the default CompuLab configuration:
```
make menuconfig
```

* Build the kernel
```
nice make -j`nproc` O=../linux-compulab-build/
```

* [Deploy the CompuLab Linux Kernel to CompuLab devices](https://github.com/compulab-yokneam/Documentation/blob/master/etc/linux_kernel_deployment.md#create-deb-package)
## Internal Build

### Yocto devtool method

Use this method in order to modify and compile compulab kernel in the Yocto environment.<br>

* Get back to the build environment:<br>
In order to use the already created build environment issue these commands:
```
cd /path/to/compulab-nxp-bsp
repo sync
source setup-environment build-${MACHINE}
```

* Get the latest source code:
```
devtool modify linux-compulab
```

* Goto the source tree:
```
cd ${BUILDDIR}/workspace/sources/linux-compulab
```

* Build the linux-compulab:
```
devtool build linux-compulab
```

* Make and commit the changes
* Apply changes from external source tree to recipe:
```
devtool update-recipe linux-compulab
```

* Remove the workspace layer:
```
bitbake-layers remove-layer ${BUILDDIR}/workspace
```

* Issue the build:
```
bitbake -k linux-compulab
```
