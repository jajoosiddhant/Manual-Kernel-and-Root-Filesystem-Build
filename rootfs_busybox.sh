# !/bin/bash
# Script to install rootfs using busybox.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/projects

if [ $# -lt 1 ]
then
	echo -e "\nUSING DEFAULT DIRECTORY ${OUTDIR}\n"
else
	OUTDIR=$1
	echo -e "\nUSING ${OUTDIR} DIRECTORY\n"
fi

if [ -d "$OUTDIR" ]
then
	echo -e "\nDIRECTORY ALREADY EXISTS\n"
else
	exit 1
fi


#Creating staging directory required for root filesystems.
echo -e "\nCREATING THE STAGING DIRECTORY REQUIRED FOR ROOT FILESYSTEM\n"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	sudo rm -rf "${OUTDIR}/rootfs"
	echo -e "\nROOTFS FOLDER DELETED\n"
fi

mkdir rootfs
cd rootfs
mkdir bin dev etc home lib proc sbin sys tmp usr var
mkdir usr/bin usr/lib usr/sbin
mkdir -p var/log
echo -e "\nROOTFS FOLDER CREATED\n"

#Changing the ownership to root user for the target device
echo -e "\nCHANGING THE OWNERSHIP OF CONTENTS OF ROOTFS TO ROOT USER\n"
sudo chown -R root:root *


#Cloning busybox in $OUTDIR
cd "$OUTDIR"
if [ -d "${OUTDIR}/busybox" ]
then
	cd busybox
	git checkout 1_31_stable
else
	echo -e "\nCLONING BUSYBOX VERSION 1_31_STABLE IN ${OUTDIR}\n"
	git clone git://busybox.net/busybox.git
	cd busybox
	git checkout 1_31_stable
	echo -e "\nCLEANING AS IF IT WAS A NEW FILE\n"
	make distclean
	#Generating a config file for busybox.
	echo -e "\nGENERATING CONFIG FILE FOR BUSYBOX\n"
	make defconfig
fi

#Make and Save the Generated Configuration.
make ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- 


#SUDO messes with the PATH environment variable. Thus you need to add "env PATH=$PATH" to your command line. Check the forum link below.
#https://www.raspberrypi.org/forums/viewtopic.php?t=209621
echo -e "\nINSTALLING BUSYBOX\n"
sudo env PATH=$PATH make CONFIG_PREFIX="${OUTDIR}/rootfs" ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- install


cd "$OUTDIR"/linux-stable
sudo env PATH=$PATH make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- INSTALL_MOD_PATH=${OUTDIR}/rootfs modules_install


cd "$OUTDIR"
cd rootfs


arm-unknown-linux-gnueabi-readelf -a bin/busybox | grep "program interpreter"
arm-unknown-linux-gnueabi-readelf -a bin/busybox | grep "Shared library"


export SYSROOT=$(arm-unknown-linux-gnueabi-gcc -print-sysroot)

#Copying necessary library files in the rootfs/lib folder.
echo -e "\nCOPYING NECESSARY LIBRARY FILES IN THE ~/ROOTFS/LIB FOLDER\n"
sudo cp -a $SYSROOT/lib/ld-linux.so.3 lib
sudo cp -a $SYSROOT/lib/ld-2.29.so lib
sudo cp -a $SYSROOT/lib/libm.so.6 lib
sudo cp -a $SYSROOT/lib/libm-2.29.so lib
sudo cp -a $SYSROOT/lib/libresolv.so.2 lib
sudo cp -a $SYSROOT/lib/libresolv-2.29.so lib
sudo cp -a $SYSROOT/lib/libc.so.6 lib
sudo cp -a $SYSROOT/lib/libc-2.29.so lib


#Making Device Nodes for minimal root filesystem.
echo -e "\nMAKING DEVICE NODES\n"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

