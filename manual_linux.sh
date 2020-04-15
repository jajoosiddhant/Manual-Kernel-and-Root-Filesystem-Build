#!/bin/bash
# Script to install and build manual kernel and root-filesystem.
# Adding and executing a hello-world executable to test the RYO kernel.

# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/projects
REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
#DIR is the path where writer executable, finder.sh and tester.sh are stored.
#Refer: https://www.electrictoolbox.com/bash-script-directory/
DIR="$( cd "$(dirname "$0")" ; pwd -P )"


if [ $# -lt 1 ]
then
	echo -e "\nUSING DEFAULT DIRECTORY ${OUTDIR} TO STORE FILES\n"
else
	OUTDIR=$1
	echo -e "\n USING ${OUTDIR} DIRECTORY TO STORE FILES\n"
fi

if [ -d "$OUTDIR" ]
then
	echo -e "\nDIRECTORY ALREADY EXISTS\n"
#	rm -rf "$OUTDIR"/*
else
	mkdir -p "$OUTDIR"
	
	if [ -d "$OUTDIR" ]
	then
		echo -e "\n${OUTDIR} CREATED\n"
	else
		echo -e "\nCANNOT CREATE ${OUTDIR}\n"
	exit 1
	fi
fi

#Installing Dependencies
echo -e "\nINSTALLING THE REQUIRED DEPENDENCIES FOR THE INSTALLATION\n"
sudo apt-get install -y libssl-dev
sudo apt-get install -y u-boot-tools
sudo apt-get install -y qemu


#Clone only if the repository does not exists.
cd "$OUTDIR"
if [ -d "${OUTDIR}/linux-stable" ]
then
	cd linux-stable
	echo -e "\nCHECKING OUT VERSION 5.1.10\n"
	git checkout v5.1.10
else
	echo -e "\nCLONING GIT LINUX STABLE VERSION 5.1.10 IN ${OUTDIR}\n"
	git clone "$REPO"
	cd linux-stable
	git checkout v5.1.10
	echo -e "\nERASING EVERYTHING AS IF IT WAS A NEW UNZIPPED FILE\n"
	make ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- mrproper
	echo -e "\nGENERATING A CONFIG FILE\n"
	#Creating .config file using Kconfig files.
	make ARCH=arm versatile_defconfig
fi

#Building zImage
echo -e "\nGENERATING A ZIMAGE\n"
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- zImage


#Building Modules
echo -e "\nBUILDING MODULES\n"
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- modules


#Building dtbs files
echo -e "\nBUILDING DTBS FILES\n"
make  ARCH=arm CROSS_COMPILE=arm-unknown-linux-gnueabi- dtbs


#Copy and pasting the Zimage and dtbs files in $OUTDIR
echo -e "\nCOPY AND PASTING THE ZIMAGE IN ${OUTDIR}\n"
cp "${OUTDIR}/linux-stable/arch/arm/boot/zImage" "${OUTDIR}"


echo -e "\nCOPY AND PASTING THE DTBS FILES IN ${OUTDIR}\n"
cp "${OUTDIR}/linux-stable/arch/arm/boot/dts/versatile-pb.dtb" "${OUTDIR}"


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


#Cleaning Old writer Utility and building again.
echo -e "\nCLEANING OLD WRITER UTILITING AND BUILDING AGAIN\n"
cd ${DIR}/ && make clean
cd ${DIR}/ && make CROSS_COMPILE=arm-unknown-linux-gnueabi-


#Copying writer executable, tester.sh and finder.sh here
echo -e "\nCOPYING WRITER, TESTER.SH AND FINDER.SH TO ${OUTDIR}/rootfs/bin\n"
sudo cp "${DIR}/hello-world" "${OUTDIR}/rootfs/home"



#CONFIG_BLK_DEV_INITRD is already configured.
#Creating Initramfs

echo -e "\nCREATING STANDALONE INITRAMFS .CPIO FILE\n"

cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd "${OUTDIR}"
#-f is written below in order to force it to overwrite if initramfs.cpio already exists.
gzip -f initramfs.cpio

#Booting the kernel
echo -e "\nBOOTING THE KERNEL\n"
echo QEMU_AUDIO_DRV=none qemu-system-arm -m 256M -nographic -M versatilepb -kernel zImage -append "console=ttyAMA0 rdinit=/bin/sh" -dtb versatile-pb.dtb -initrd initramfs.cpio.gz
QEMU_AUDIO_DRV=none qemu-system-arm -m 256M -nographic -M versatilepb -kernel zImage -append "console=ttyAMA0 rdinit=/bin/sh" -dtb versatile-pb.dtb -initrd initramfs.cpio.gz
