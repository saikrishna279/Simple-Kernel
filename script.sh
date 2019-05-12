#!/bin/bash

#keng some script stuff

#color stuff
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'
blue='\033[0;34m'
cyan='\033[0;36m'

#text styling stuff
bold=$(tput bold)
normal=$(tput sgr0)

#init stuff
KERNEL_DIR=`readlink -f .`
KERNEL="MalO"
DEVICE="beryllium"
ARCH="arm64"
CROSS_COMPILE="/home/${USER}/toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
CROSS_COMPILE_ARM32="/home/${USER}/toolchain/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
CCACHE_DIR="~/.ccache"
OUT="out"

#clang
CC="/home/${USER}/toolchain/clang/clang-r353983c/bin/clang"
CLANG_TRIPLE="aarch64-linux-gnu-"

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
#export ARCH="${ARCH}"
#export CROSS_COMPILE="${CROSS_COMPILE}"
#export CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}"
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
rm -f ${KERNEL_DIR}/out/arch/arm64/boot/Image
echo -e "${green}Done!${white}"
}

function build(){
echo -n -e "${red}Clean before compiling?${white} Y/N?"
read ass
if [[ $ass == "Y" || $ass == "y" ]]; then
clean
fi
echo -e "${green}Starting build now!${white}"
make O="${OUT}" ARCH="${ARCH}" "${KERNEL}_defconfig"
make -j$(nproc --all) O="${OUT}" \
                      ARCH="${ARCH}" \
                      CC="${CC}" \
                      CLANG_TRIPLE="${CLANG_TRIPLE}" \
		      CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}" \
                      CROSS_COMPILE="${CROSS_COMPILE}"
if [ -a ${zimage} ]; then
	echo -e "${green}Build successfully completed!${white} Start compression? (Y/N)"
read xxx
if [[ $xxx == "Y" || $xxx == "y" ]]
then
	mkzip
elif [[ $xxx == "N" || $xxx == "n" ]]
then
	echo "Okay then! Cya..."
fi
fi
}

function log(){
echo -e "${bold}${red}BEGIN LOG${white}${normal}"
cat ${KERNEL_DIR}/buildlog.txt
echo -e "${bold}${red}END LOG${white}${normal}"
}

function mkzip(){
echo -e "${green}Generating flashable ZIP...${white}"
mkdir -p ${KERNEL_DIR}/build
cd ${KERNEL_DIR}/build/
rm Image.gz-dtb
cp ${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb ${KERNEL_DIR}/build/
cd ${KERNEL_DIR}/build/
zip -r ${zip_name} ${KERNEL_DIR}/build/*
echo -e "${blue}Done!${white}"
cd ${KERNEL_DIR}
}
