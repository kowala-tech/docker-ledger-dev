################################################################
# Kowala Ledger development tooling.
#
# This image can be used to compile (and, on Linux, load) Ledger
# Nano S and Blue applications. It uses an Ubuntu-based system
# with the official GCC-ARM and LLVM images, as well as the
# current stable Nano S and Blue SDKs.
#
# To use the system for development, mount a volume containing
# your application at `/home/workspace`, and then build as
# normal. For example, if your application is built by a 
# Makefile:
#
# docker run -v `pwd`:/home/workspace kowalatech/ledger make  
#
# On Linux, you can also mount your USB bus and load the binary
# onto a device:
#
# docker run --privileged \
#            -v /dev/bus/usb:/dev/bus/usb \
#            -v `pwd`:/home/workspace \ 
#            kowalatech/ledger make load
#
# NOTE: There's a conflict in Ubuntu between Python versions 2
# and three. The command `python` uses version 2, and `python3`
# version 3. If you're calling the python command directly (for
# example in Makefiles), use python3. For systems that use v3
# defaultly (ie, `python` is v3) then the Docker image provides
# a PYTHON environment variable for easy interpolation.
#
# ANOTHER NOTE: If you're loading the binary to a device using
# a Linux host, yopu must add the udev rules (as described in
# https://github.com/LedgerHQ/blue-loader-python's README.md.
#
################################################################

FROM        ubuntu:artful
MAINTAINER  Kowala Tech <dev@kowala.tech>

################################################################
# Tool setup
################################################################

RUN apt-get update && \
    apt-get -y install \ 
		cmake \
		git \
		build-essential \
		vim \
		python3 python3-pip python-pip python-dev virtualenv \
		wget \
		libc6-i386 libc6-dev-i386 \
		libudev-dev libusb-1.0-0-dev

################################################################
# BOLOS dev envitonment setup
################################################################

RUN mkdir /opt/ledger-blue

RUN cd /opt/ledger-blue && \
    wget -O - https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q1-update/+download/gcc-arm-none-eabi-5_3-2016q1-20160330-linux.tar.bz2 | tar xjvf -

RUN cd /opt/ledger-blue && \
    wget -O - http://releases.llvm.org/4.0.0/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz | tar xJvf - && mv clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04 clang-arm-fropi

ENV PATH /opt/ledger-blue/clang-arm-fropi/bin:/opt/ledger-blue/gcc-arm-none-eabi-5_3-2016q1/bin:$PATH
ENV BOLOS_ENV /opt/ledger-blue

################################################################
# BOLOS, Blue and Nano S SDK setup
################################################################

RUN cd /home && \
    git clone --branch nanos-1421 https://github.com/LedgerHQ/nanos-secure-sdk.git && \
	git clone --branch blue-r23 https://github.com/LedgerHQ/blue-secure-sdk.git

# Default is the Nano S.
ENV BOLOS_SDK /home/nanos-secure-sdk

################################################################
# Application workspace. Mount local applications here
################################################################

RUN mkdir /home/workspace
WORKDIR /home/workspace

# There's a conflict in ubuntu betweens Python versions 2 and 3.
# To get around that, we set a environment variable to instruct
# tooling to use the binary `python3`.
ENV PYTHON python3
RUN cd /home/workspace && pip3 install pillow && pip install pillow

# For loading to work, we also need the Python loader
RUN virtualenv ledger && pip3 install ledgerblue
  
