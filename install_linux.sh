# !/bin/bash
# Script to install linux kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/projects
REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git


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


#Clone only if the repository does not exists.
cd "$OUTDIR"
if [ -d "${OUTDIR}/linux-stable" ]
then
	cd linux-stable
	echo -e "\nCHECKING OUT LINUX VERSION 5.1.10\n"
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

