#!/bin/bash

# Custom Kernel build script

# Constants
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
cyan='\033[0;36m'
yellow='\033[0;33m'
blue='\033[0;34m'
default='\033[0m'

# Resources
KERNEL_DIR=$PWD
IMAGE=$KERNEL_DIR/arch/arm64/boot/Image
#IMAGE=$KERNEL_DIR/arch/arm/boot/zImage for 32 bit architecture
DTBTOOL=$KERNEL_DIR/scripts/dtbToolCM
TOOLCHAIN=/home/techie/dnd/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin

#Paths
OUT_DIR=$KERNEL_DIR/out
OUT_ZIP=$KERNEL_DIR/Releases
MODULE_DIR=$OUT_DIR/modules
NEW_OUT=$OUT_DIR

# Kernel Version Info
BASE="Nucleon™-Kernel-"
CUR_VER="V1"
NUCLEON_VER="$BASE$CUR_VER"
CUR_TIME="$(date "+%y.%m.%d-%H.%M.%S")"
# Variables

DEFCONFIG="mido_defconfig"
export CROSS_COMPILE=$TOOLCHAIN/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="DarkKnight6499"
export KBUILD_BUILD_HOST="Cryofire"

function make_nucleon {
		echo -e "$green*******************************************************"
		echo "                  Compiling $NUCLEON_VER	              "
		echo -e "*****************************************************"
		echo
                mkdir Releases 
		make $DEFCONFIG
		make -j4
		rm -rf $NEWOUT/Image
		cp -vr $IMAGE $NEW_OUT/zImage
		make_dtb
                make_modules
		make_zip
		housekeeping
		echo -e "$green*******************************************************"
		echo "              Compilation Completed!!              "
		echo -e "*****************************************************$default"
		}

		
function make_onlyclean {
                echo -e "$green***********************************************"
                echo "          Cleaning up object files and other stuff                      "
                echo -e "***********************************************$default"
                make clean
                make mrproper
}
function make_clean {
		echo -e "$green***********************************************"
		echo "          Cleaning up object files and other stuff	              "
		echo -e "***********************************************$default"
                make clean
		make mrproper
		make_nucleon
	}
		
function make_recompile {
			echo -e "$cyan*******************************************************"
			echo "             Recompiling $NUCLEON_VER	              "
			echo -e "*****************************************************"
			make -j4
			rm -rf $NEWOUT/Image
			cp -vr $IMAGE $NEW_OUT
			make_dtb
                        make_modules		
			make_zip
			housekeeping
		}
		
function make_dtb {
			echo -e "$blue*******************************************************"
			echo "             		Creating dt.img....	              "
			echo -e "*****************************************************"
			rm -rf $NEWOUT/dtb
			$DTBTOOL -v -s 2048 -o $NEW_OUT/dtb -p scripts/dtc/ arch/arm/boot/dts/
		}


function make_modules {
		rm -rf $MODULE_DIR/*
		echo -e "$cyan*******************************************************"
		echo "             Finding modules....	              "
		echo -e "*****************************************************"
                find . -path ./build -prune -o -name '*.ko' -print | xargs cp -t $MODULE_DIR/
		cd $KERNEL_DIR
                }


function make_zip {
		echo -e "$yellow*******************************************************"
		echo "             		Zipping up....	              "
		echo -e "*****************************************************"
		cd $OUT_DIR
		rm -f '*.zip'
		zip -r9 Nucleon-Mido-`echo $CUR_VER``echo $CUR_TIME`.zip *
		mv Nucleon-Mido-`echo $CUR_VER``echo $CUR_TIME`.zip $OUT_ZIP
		echo "Find your zip in Release directory"
		echo -e "$default"
		cd $KERNEL_DIR 
		}

function housekeeping {
		echo -e "$green*******************************************************"
		echo "            Cleaning up the mess created...	              "
		echo -e "*****************************************************$default"
		rm -rf $NEW_OUT/Image
		rm -rf $NEW_OUT/dtb
	}
		

BUILD_START=$(date +"%s")
while read -p " 'A' to Compile Again , 'D' to Compile Dirty , 'C' to do a clean compilation , 'E' to do clean only , 'N' to exit " choice
do
case "$choice" in
	a|A)
		make_nucleon
		break
		;;
	d|D )
		make_recompile
		break
		;;
	c|C )
		make_clean
		break;
		;;
        e|E )
                make_onlyclean
                break;
                ;;
	n|N )
		break
		;;
	* )
		echo
		echo "Failed !"
		echo
		;;
esac
done
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Nucleon Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$default"
