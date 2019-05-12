#!/bin/bash

#keng some script stuff

#color stuff
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'
blue='\033[0;34m'
cyan='\033[0;36m'

#init stuff
KERNEL_DIR=`readlink -f .`
KERNEL="MalO"
DEVICE="beryllium"
ARCH="arm64"
CROSS_COMPILE="/home/${USER}/toolchain/gcc-linaro-7.4.1/bin/aarch64-linux-gnu-"
CROSS_COMPILE_ARM32="/home/${USER}/toolchain/gcc-linaro-7.4.1-32/bin/arm-linux-gnueabi-"
CCACHE_DIR="~/.ccache"
OUT="out"

#smore stuff
zimage="${KERNEL_DIR}/out/arch/arm64/boot/Image"
time=$(date +"%d-%m-%y-%T")
date=$(date +"%d-%m-%y")
build_type="gcc"
v=$(grep "CONFIG_LOCALVERSION=" "${KERNEL_DIR}/arch/arm64/configs/${KERNEL}_defconfig" | cut -d- -f3- | cut -d\" -f1)
zip_name="${KERNEL}-ver${v}-${DEVICE}-${date}.zip"

#build fields
export KBUILD_BUILD_USER="definitely-not-AI"
export KBUILD_BUILD_HOST="SCP-079"
export ARCH="${ARCH}"
export CROSS_COMPILE="${CROSS_COMPILE}"
export CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}"
export USE_CCACHE=1
export CCACHE_DIR=$CCACHE_DIR
ccache -M 50G

echo -e "${green}Script has initialzed build with following DIR's${white}"
echo -e "kerneldir = ${red}${KERNEL_DIR}${white}"
echo -e "ccache dir = ${red}${CCACHE_DIR}${white}"
echo -e "Building as ${yellow}${KBUILD_BUILD_USER}${white}@${blue}${KBUILD_BUILD_HOST}${white}"


function clean(){
echo -e "${red}Cleaning...${white}"
make clean && make mrproper
rm ${KERNEL_DIR}/out/arch/arm64/boot/Image
echo -e "${green}Done!${white}"
}

function build(){
echo -e "${green}Starting build now!${white}"
make O="${OUT}" "${KERNEL}_defconfig"
make O="${OUT}" -j$(nproc --all) &>buildlog.txt & pid=$!
}

