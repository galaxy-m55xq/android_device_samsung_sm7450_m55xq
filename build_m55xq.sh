#!/bin/bash

# DIR Setting
SCRIPT_DIR="$(dirname $(readlink -fq $0))"

# OEM Setting
BUILD_TARGET=m55xq_swa_open
export MODEL=$(echo $BUILD_TARGET | cut -d'_' -f1)
export PROJECT_NAME=${MODEL}
export REGION=$(echo $BUILD_TARGET | cut -d'_' -f2)
export CARRIER=$(echo $BUILD_TARGET | cut -d'_' -f3)
export TARGET_BUILD_VARIANT=user

CHIPSET_NAME=x55
export ANDROID_BUILD_TOP=$(pwd)
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki

export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${MODEL}
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-${CHIPSET_NAME}-${CHIPSET_NAME}-${TARGET_PRODUCT}
export DIST_DIR=${ANDROID_BUILD_TOP}/out/msm-${CHIPSET_NAME}-${CHIPSET_NAME}-${TARGET_PRODUCT}/dist
export MERGE_CONFIG="${ANDROID_BUILD_TOP}/kernel_platform/common/scripts/kconfig/merge_config.sh"

mkdir -p "${DIST_DIR}"

export IS_KBUILD=true
export MODNAME=audio_dlkm

export EXT_MODULES=" \
    ../vendor/qcom/opensource/mmrm-driver \
    ../vendor/qcom/opensource/audio-kernel \
    ../vendor/qcom/opensource/datarmnet/core \
    ../vendor/qcom/opensource/datarmnet-ext/shs \
    ../vendor/qcom/opensource/datarmnet-ext/sch \
    ../vendor/qcom/opensource/datarmnet-ext/perf \
    ../vendor/qcom/opensource/datarmnet-ext/perf_tether \
    ../vendor/qcom/opensource/datarmnet-ext/offload \
    ../vendor/qcom/opensource/datarmnet-ext/aps \
    ../vendor/qcom/opensource/datarmnet-ext/wlan \
    ../vendor/qcom/opensource/wlan/qcacld-3.0 \
    ../vendor/qcom/opensource/camera-kernel \
    ../vendor/qcom/opensource/display-drivers/msm \
    ../vendor/qcom/opensource/video-driver \
    ../vendor/qcom/opensource/eva-kernel \
    ../vendor/qcom/opensource/cvp-kernel \
    ../vendor/qcom/opensource/dataipa/drivers/platform/msm"

export GKI_KERNEL_BUILD_OPTIONS=" \
    SKIP_MRPROPER=1 \
    LTO=thin \
    HERMETIC_TOOLCHAIN=1 \
    KMI_SYMBOL_LIST_STRICT_MODE=0 \
    RECOMPILE_KERNEL=1 \
    ABI_DEFINITION= \
    BUILD_BOOT_IMG=1 \
    SKIP_VENDOR_BOOT=1 \
    MKBOOTIMG_PATH=${ANDROID_BUILD_TOP}/kernel_platform/tools/mkbootimg/mkbootimg.py \
    KERNEL_BINARY=Image \
    BOOT_IMAGE_HEADER_VERSION=4 \
    AVB_SIGN_BOOT_IMG=1 \
    AVB_BOOT_PARTITION_SIZE=100663296 \
    AVB_BOOT_KEY=${ANDROID_BUILD_TOP}/kernel_platform/tools/mkbootimg/tests/data/testkey_rsa2048.pem \
    AVB_BOOT_ALGORITHM=SHA256_RSA2048 \
    AVB_BOOT_PARTITION_NAME=boot \
"

export MKBOOTIMG_EXTRA_ARGS=" \
    --os_version 12.0.0 \
    --os_patch_level 2025-12-00 \
    --pagesize 4096 \
"

# Cook kernel

env ${GKI_KERNEL_BUILD_OPTIONS} ${ANDROID_BUILD_TOP}/kernel_platform/build/android/prepare_vendor.sh sec ${TARGET_PRODUCT} | tee -a build.log

# Copy boot.img

cp ${DIST_DIR}/boot.img ${ANDROID_BUILD_TOP}/boot.img

