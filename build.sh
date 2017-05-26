#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="karate_defconfig"
KERNEL="zImage-dtb"

# Hyper Kernel Details
BASE_VER="hyper-n"
VER="-$(date +"%Y-%m-%d"-%H%M)-"
K_VER="$BASE_VER$VER$TC"


# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=karthick111
#export KBUILD_BUILD_HOST=


# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/karthick111/kernel/karate"
ANYKERNEL_DIR="$RESOURCE_DIR/hyper"
TOOLCHAIN_DIR="/home/karthick111/kernel/gcc"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"


# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
		make $KERNEL $THREAD
                make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		cd $KERNEL_DIR
		make modules $THREAD
                mkdir $MODULES_DIR
		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
		cd $MODULES_DIR
        $STRIP --strip-unneeded *.ko
        cd $KERNEL_DIR
}

function make_zip {
		cd $REPACK_DIR
                zip -r `echo $K_VER$TC`.zip *
                mkdir $ZIP_MOVE
		mv  `echo $K_VER$TC`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

                TC="gcc"
		export CROSS_COMPILE=$TOOLCHAIN_DIR/arm-eabi-4.8/bin/arm-eabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/arm-eabi-4.8/lib/
                STRIP=$TOOLCHAIN_DIR/arm-eabi-4.8/bin/arm-eabi-strip
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		cd $ANYKERNEL_DIR
		rm -rf zImage
                cd $KERNEL_DIR
		#make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Hyper Kernel Using arm-eabi-4.8 Toolchain"

echo -e "${restore}"

		make_kernel
                make_modules
		make_zip

echo -e "${green}"
echo $K_VER$TC.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
cd $ZIP_MOVE
ls
