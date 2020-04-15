# Manual-Kernel-and-Root-Filesystem-Build 


Execute the following commands to install crosstool-ng in the current working directory and then start the build for manual kernel. 
```
./crosstool-NG-install.sh
./manual_linux.sh
```
This will lead to qemu booting up.

You can find the hello-world example in the home directory inside qemu to execute and test if the executable has been cross-compiled and executes inside qemu.

## References
- Mastering Embedded Linux Programming - Second Edition by Chris Simmonds
- Course content of Advanced Embedded Software Development (AESD) from University of Colorado, Boulder.
