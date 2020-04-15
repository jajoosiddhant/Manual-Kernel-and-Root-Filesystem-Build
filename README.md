# Manual-Kernel-and-Root-Filesystem-Build 


Execute the following commands to install crosstool-ng in the current working directory for `arm-unknown-lunux-gnueabi` and then start the build for manual kernel.  

```
./crosstool-NG-install.sh
./manual_linux.sh
```

Make sure to add path for the cross-compile utility `arm-unknown-linux-gnueabi` located in the x-tools folder before running manual_linux.sh script. 


Steps to add path in .bashrc file:  
Open the .bashrc file located in the home directory of the host machine.  
Enter the following line at the end of the file:  
`export PATH=<path-to-x-tool-folder>/x-tools/arm-unknown-linux-gnueabi/bin:$PATH`  


This will lead to qemu booting up.

You can find the hello-world example in the home directory inside qemu to execute and test if the executable has been cross-compiled and executes inside qemu.

## References
- Mastering Embedded Linux Programming - Second Edition by Chris Simmonds
- Course content of Advanced Embedded Software Development (AESD) from University of Colorado, Boulder.
