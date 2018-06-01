## Kowala Ledger development tooling.

This image can be used to compile (and, on Linux, load) Ledger
Nano S and Blue applications. It uses an Ubuntu-based system
with the official GCC-ARM and LLVM images, as well as the
current stable Nano S and Blue SDKs.

To use the system for development, mount a volume containing
your application at `/home/workspace`, and then build as
normal. For example, if your application is built by a 
Makefile:

```
docker run -v `pwd`:/home/workspace kowalatech/ledger make  
```

On Linux, you can also mount your USB bus and load the binary
onto a device:

```
docker run --privileged \
            -v /dev/bus/usb:/dev/bus/usb \
            -v `pwd`:/home/workspace \ 
            kowalatech/ledger make load
````

--------
NOTE: There's a conflict in Ubuntu between Python versions 2
and three. The command `python` uses version 2, and `python3`
version 3. If you're calling the python command directly (for
example in Makefiles), use python3. For systems that use v3
defaultly (ie, `python` is v3) then the Docker image provides
a PYTHON environment variable for easy interpolation.

ANOTHER NOTE: If you're loading the binary to a device using
a Linux host, yopu must add the udev rules (as described in
https://github.com/LedgerHQ/blue-loader-python's README.md.
