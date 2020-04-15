# !/bin/bash
# Script to save changes in the staging directory and create standalone initramfs.
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


cd "$OUTDIR"
cd rootfs

#CONFIG_BLK_DEV_INITRD is already configured.
#Creating Initramfs

echo -e "\nCREATING STANDALONE INITRAMFS .CPIO FILE\n"

cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd "${OUTDIR}"
#-f is written below in order to force it to overwrite if initramfs.cpio already exists.
gzip -f initramfs.cpio

