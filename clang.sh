#!/usr/bin/env bash
#
# Copyright (C) 2021 a xyzprjkt property
#

# Needed Secret Variable
# KERNEL_NAME | Your kernel name
# KERNEL_SOURCE | Your kernel link source
# KERNEL_BRANCH  | Your needed kernel branch if needed with -b. eg -b eleven_eas
# DEVICE_CODENAME | Your device codename
# DEVICE_DEFCONFIG | Your device defconfig eg. lavender_defconfig
# ANYKERNEL | Your Anykernel link repository
# TG_TOKEN | Your telegram bot token
# TG_CHAT_ID | Your telegram private ci chat id
# BUILD_USER | Your username
# BUILD_HOST | Your hostname

echo "Downloading few Dependecies . . ."
# Kernel Sources
git clone --depth=1 https://github.com/xyz-prjkt/xRageTC-clang xrage
# Main Declaration
KERNEL_ROOTDIR=$(pwd)/$DEVICE_CODENAME=RMX2020
DEVICE_DEFCONFIG=RMX2020_defconfig
DEVICE_CODENAME=RMX2020
KERNEL_NAME=Ninym_Kernel
TG_TOKEN=5236610770:AAFrxDGH4yEdtrIiACTiVE7ORNACycXxf1A
TG_CHAT_ID=-1001474150346
CODENAME=Ninym_Kernel
ANYKERNEL=https://github.com/rama982/AnyKernel3
CLANG_ROOTDIR=$(pwd)/xrage
export KBUILD_BUILD_USER=Ninym
export KBUILD_BUILD_HOST=Arthurleywin
CLANG_VER="$("$CLANG_ROOTDIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
LLD_VER="$("$CLANG_ROOTDIR"/bin/ld.lld --version | head -n 1)"
export KBUILD_COMPILER_STRING="$CLANG_VER with $LLD_VER"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
TANGGAL=$(date +"%Y%m%d-%H")
START=$(date +"%s")
PATH="${PATH}:${CLANG_ROOTDIR}/bin"

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo KernelCompiler
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo TOOLCHAIN_VERSION = ${KBUILD_COMPILER_STRING}
echo CLANG_ROOTDIR = ${CLANG_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}

# Telegram
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"

}

# Post Main Information
tg_post_msg "<b>xKernelCompiler</b>%0ABuilder Name : <code>${KBUILD_BUILD_USER}</code>%0ABuilder Host : <code>${KBUILD_BUILD_HOST}</code>%0ADevice Defconfig: <code>${DEVICE_DEFCONFIG}</code>%0AClang Version : <code>${KBUILD_COMPILER_STRING}</code>%0AClang Rootdir : <code>${CLANG_ROOTDIR}</code>%0AKernel Rootdir : <code>${KERNEL_ROOTDIR}</code>"

# Compile
compile(){
tg_post_msg "<b>xKernelCompiler:</b><code>Compilation has started</code>"
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
make -j$(nproc) ARCH=arm64 O=out \
    CC=${CLANG_ROOTDIR}/bin/clang \
    CROSS_COMPILE=${CLANG_ROOTDIR}/bin/aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=${CLANG_ROOTDIR}/bin/arm-linux-gnueabi-

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi

  git clone --depth=1 $ANYKERNEL AnyKernel
	cp $IMAGE AnyKernel
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>$DEVICE_CODENAME</b> | <b>${KBUILD_COMPILER_STRING}</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $KERNEL_NAME-$CODENAME-${TANGGAL}.zip *
    cd ..
}
check
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push