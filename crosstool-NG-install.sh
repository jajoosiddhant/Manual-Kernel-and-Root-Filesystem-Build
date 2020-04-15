#!/bin/bash
# This script would install crosstool-ng in the current working directory

sudo apt-get install automake bison chrpath flex g++ git gperf \
gawk libexpat1-dev libncurses5-dev libsdl1.2-dev libtool \
python2.7-dev texinfo help2man libtool-bin
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
git checkout crosstool-ng-1.24.0
./bootstrap
./configure --enable-local
make
./ct-ng distclean
./ct-ng arm-unknown-linux-gnueabi
cp ../crosstool-config .config
./ct-ng build
