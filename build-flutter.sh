#!/bin/bash

SOURCE_DIR=$(realpath $1)
TARGET_DIR=$(realpath $(dirname $0))

BUILD_PROFILE=$2

if [ ! -d ${SOURCE_DIR}/flutter ] || [ -z ${BUILD_PROFILE} ]; then
	echo "Usage: $(basename $0) path-to-flutter-src profile"
	exit
fi
BINARY_DIR=${SOURCE_DIR}/out/linux_${BUILD_PROFILE}_arm

cd ${SOURCE_DIR}/flutter
COMMIT_ID=$(git rev-parse HEAD)

ENGINE_REVISION=${COMMIT_ID:0:10}

if [ -z ${ENGINE_REVISION} ]; then
	exit
fi

cd ${SOURCE_DIR}

./flutter/tools/gn                                                      \
	--target-toolchain /opt/llvm-cross/arm-linux-gnueabi/toolchain  \
	--target-sysroot /opt/llvm-cross/arm-linux-gnueabi/sysroot      \
	--target-triple arm-linux-gnueabi                               \
	--arm-float-abi softfp                                          \
	--target-os linux                                               \
	--linux-cpu arm                                                 \
	--runtime-mode ${BUILD_PROFILE}                                 \
	--embedder-for-target                                           \
	--enable-fontconfig                                             \
	--disable-desktop-embeddings                                    \
        --no-full-dart-sdk                                              \
	--no-build-glfw-shell                                           \
	--no-goma                                                       \
	--no-lto

ninja -C ${BINARY_DIR} -k 100

ENGINE_DIR=${TARGET_DIR}/${BUILD_PROFILE}/${ENGINE_REVISION}

mkdir -p ${ENGINE_DIR}

cd ${BINARY_DIR}

cp -t ${ENGINE_DIR} libflutter_engine.so icudtl.dat flutter_embedder.h
