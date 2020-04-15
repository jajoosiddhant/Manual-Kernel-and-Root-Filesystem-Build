# !/bin/bash
# Script to copy the executables in rootfs/bin directory.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/projects
#DIR is the path where writer executable, finder.sh and tester.sh are stored.
#Refer: https://www.electrictoolbox.com/bash-script-directory/
DIR="$( cd "$(dirname "$0")" ; pwd -P )"


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


#Cleaning Old writer Utility and building again.
echo -e "\nCLEANING OLD WRITER UTILITING AND BUILDING AGAIN\n"
cd ${DIR}/ && make clean
cd ${DIR}/ && make CROSS_COMPILE=arm-unknown-linux-gnueabi-


#Copying writer executable, tester.sh and finder.sh here
echo -e "\nCOPYING WRITER, TESTER.SH AND FINDER.SH TO ${OUTDIR}/rootfs/bin\n"
sudo cp "${DIR}/hello-world" "${OUTDIR}/rootfs/home"




