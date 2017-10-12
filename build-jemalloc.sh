#!/bin/sh
# Copyright 2016 Mozilla
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

ROOT_DIR=`pwd`
WORK_DIR="jemalloc"

JEMALLOC_VERSION="5.0.1"
ARCHS=("i386" "armv7" "armv7s" "arm64" "x86_64")
IOS_SDK_VERSION="11.0"

if [ -d "${WORK_DIR}/download" ]; then
  rm -rf "${WORK_DIR}/download"
fi

if [ -d "${WORK_DIR}/src" ]; then
  rm -rf "${WORK_DIR}/src"
fi

mkdir -p "${WORK_DIR}/download"
mkdir -p "${WORK_DIR}/src"

JEMALLOC_DOWNLOAD_SRC="https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2"
JEMALLOC_DOWNLOAD_DST="${WORK_DIR}/download/jemalloc-${JEMALLOC_VERSION}.tar.bz2"
curl -Lo ${JEMALLOC_DOWNLOAD_DST} ${JEMALLOC_DOWNLOAD_SRC}

if [ $? -eq 0 ]; then
    tar xjf ${JEMALLOC_DOWNLOAD_DST} -C ${WORK_DIR}/src

    if [ $? -eq 0 ]; then
        for ARCH in "${ARCHS[@]}"; do
            cd "${ROOT_DIR}"

            if [ -d "${WORK_DIR}/output/${ARCH}" ]; then
                rm -rf "${WORK_DIR}/output/${ARCH}"
            fi
            mkdir -p "${WORK_DIR}/output/${ARCH}"
            cp -R "${WORK_DIR}/src/jemalloc-${JEMALLOC_VERSION}/" "${WORK_DIR}/output/${ARCH}"

            if [ -d "${WORK_DIR}/install/${ARCH}" ]; then
                rm -rf "${WORK_DIR}/install/${ARCH}"
            fi
            mkdir -p "${WORK_DIR}/install/${ARCH}"

            if [ $ARCH == "i386" ] || [ $ARCH == "x86_64" ]; then
                PLATFORM="iPhoneSimulator"
            else
                PLATFORM="iPhoneOS"
            fi

            BUILD_SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${IOS_SDK_VERSION}.sdk"

            export LDFLAGS="-arch ${ARCH} -pipe -isysroot ${BUILD_SDKROOT} -miphoneos-version-min=10.0 -Os"
            export CFLAGS=${LDFLAGS}

            export CPPFLAGS="${CFLAGS} -w"
            export CXXFLAGS=${CXXFLAGS}

            export CC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
            export CCXX="${CC}++"

            cd "${ROOT_DIR}/${WORK_DIR}/output/${ARCH}"

            if [ -d "${WORK_DIR}/download" ]; then
                rm -rf "${WORK_DIR}/download"
            fi

            if [ $ARCH == "arm64" ]; then
                HOST="aarch64"
            else
                HOST="${ARCH}"
            fi

            ./configure --host="${HOST}-apple-darwin" \
                --prefix="${ROOT_DIR}/${WORK_DIR}/install/${ARCH}" \
                --disable-zone-allocator \
                --disable-utrace \
                --disable-debug

            if [ $? -eq 0 ]; then
                make

                if [ $? -eq 0 ]; then
                    make install

                    if [ $? -ne 0 ]; then
                        echo "Error installing: ${ARCH}"
                    fi
                else
                    echo "Error compiling: ${ARCH}"
                fi
            else
                echo "Error configuring: ${ARCH}"
            fi
        done

        cd "${ROOT_DIR}/${WORK_DIR}"
        if [ -f "libjemalloc.a" ]; then
            rm -f "libjemalloc.a"
        fi

        LIPO_CMD="lipo -create"
        for ARCH in "${ARCHS[@]}"; do
            if [ -f "${ROOT_DIR}/${WORK_DIR}/install/${ARCH}/lib/libjemalloc.a" ]; then
                LIPO_CMD="$LIPO_CMD ${ROOT_DIR}/${WORK_DIR}/install/${ARCH}/lib/libjemalloc.a"
            fi
        done

        LIPO_CMD="$LIPO_CMD -output libjemalloc.a"
        eval $LIPO_CMD

        if [ $? -ne 0 ]; then
            echo "Error creating flat library"
        fi
    else
        echo "Error uncompressing"
    fi
else
    echo "Error downloading"
fi
