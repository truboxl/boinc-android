#!/bin/sh
# This file should be sourced and not executed

# References
# https://developer.android.com/ndk/guides/other_build_systems
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md
#
# openssl/NOTES.ANDROID
# curl/INSTALL.md
# 
# https://boinc.berkeley.edu/trac/wiki/BuildSystem

# Sources version
export OPENSSL_VER=1.1.1g
export CURL_VER=7.69.1
export NDK_VER=r21c

# make
export MAKEFLAGS="${MAKEFLAGS:--j2}"

# Android NDK
export NDK="${NDK:-${PWD}/src/android-ndk-${NDK_VER}}"

# NDK OS Variant    Host Tag
# macOS             darwin-x86_64
# Linux             linux-x86_64
# 32-bit Windows    windows
# 64-bit Windows    windows-x86_64
case "$(uname)" in
    Linux)
        export HOST_TAG='linux-x86_64'
        ;;
    Darwin)
        export HOST_TAG='darwin-x86_64'
        ;;
    MSYS*|MINGW*)
        export HOST_TAG='windows-x86_64'
        ;;
    *)
        export HOST_TAG="${HOST_TAG:-linux-x86_64}"
        ;;
esac

# Name          arch    ABI         triple
# 32-bit ARMv7  arm     armeabi-v7a arm-linux-androideabi
# 64-bit ARMv8  aarch64 arm64-v8a   aarch64-linux-android
# 32-bit Intel  x86     x86         i686-linux-android
# 64-bit Intel  x86_64  x86_64      x86_64-linux-android
export ARCH="${ARCH:-aarch64}"
if [ -z "$ARCH" ]; then
    export ARCH='unknown'
fi
export TARGET="${ARCH}-linux-android"
export ABI="$ARCH"
if [ "$ARCH" = 'aarch64' ]; then
    export ABI='arm64-v8a'
elif [ "$ARCH" = 'arm' ]; then
    export TARGET="${TARGET}eabi"
    export ABI="${ARCH}eabi-v7a"
elif [ "$ARCH" = 'x86' ]; then
    export TARGET='i686-linux-android'
fi

# minSdkVersion
# API 23    6.0 fix stderr stdin stdout undefined in OpenSSL / cURL
# API 21    5.0 support 64bit / mandate PIE
# API 19    4.4 fix sys/swap.h
# API 16    4.1 lowest version to run PIE
export API="${API:-21}"

# Compile
export TOOLCHAIN="${NDK}/toolchains/llvm/prebuilt/${HOST_TAG}"
if [ -z "$OLDPATH" ]; then
    export OLDPATH="$PATH"
fi
export PATH="${TOOLCHAIN}/bin:${PATH}"
export ADDR2LINE="${TARGET}-addr2line"
export AR="${TARGET}-ar"
export AS="${TARGET}-as"
export CC="${TARGET}${API}-clang"
export CXX="${TARGET}${API}-clang++"
if [ "$ARCH" = 'arm' ]; then
    export CC="armv7a-linux-androideabi${API}-clang"
    export CXX="armv7a-linux-androideabi${API}-clang++"
fi
export CXXFILT="${TARGET}-c++filt"
export DWP="${TARGET}-dwp"
export ELFEDIT="${TARGET}-elfedit"
export GPROF="${TARGET}-gprof"
export LD="${TARGET}-ld"
export NM="${TARGET}-nm"
export OBJCOPY="${TARGET}-objcopy"
export OBJDUMP="${TARGET}-objdump"
export RANLIB="${TARGET}-ranlib"
export READELF="${TARGET}-readelf"
export SIZE="${TARGET}-size"
export STRIP="${TARGET}-strip"
export STRINGS="${TARGET}-strings"
export SYSROOT="${TOOLCHAIN}/sysroot"

# arm vfpv3-d16 fix
if [ "$ARCH" = 'arm' ]; then
    export CFLAGS="${CFLAGS} -mfloat-abi=softfp -mfpu=vfpv3-d16"
    export CXXFLAGS="${CXXFLAGS} -mfloat-abi=softfp -mfpu=vfpv3-d16"
fi

# OpenSSL
export ANDROID_NDK_ROOT="$NDK" # Used by OpenSSL 3, currently broken
export ANDROID_NDK_HOME="$NDK" # Used by OpenSSL 1.1
export OPENSSL_DIR="${PWD}/buildcache/ssl-${ARCH}-${API}"
if [ "$ARCH" = 'aarch64' ]; then
    export ARCH_SSL='arm64'
else
    export ARCH_SSL="$ARCH"
fi
export OPENSSL_ARGS="android-${ARCH_SSL} no-shared no-dso -D__ANDROID_API__=${API} --prefix=${OPENSSL_DIR} --openssldir=${OPENSSL_DIR}"

# curl
export CURL_DIR="${PWD}/buildcache/curl-${ARCH}-${API}"
export CURL_ARGS="--host=${TARGET} --with-pic --disable-shared --with-ssl=${OPENSSL_DIR} --with-sysroot=${SYSROOT} --prefix=${CURL_DIR}"

# BOINC
case "$ARCH" in
    'aarch64')
        export BOINC_PLATFORM='--with-boinc-platform=aarch64-android-linux-gnu'
        export BOINC_ALT_PLATFORM='--with-boinc-alt-platform=arm-android-linux-gnu'
        export BOINC_ARGS_EXTRA=''
        ;;
    'arm')
        export BOINC_PLATFORM='--with-boinc-platform=arm-android-linux-gnu'
        export BOINC_ALT_PLATFORM=''
        export BOINC_ARGS_EXTRA='--disable-largefile'
        ;;
    'x86_64')
        export BOINC_PLATFORM='--with-boinc-platform=x86_64-android-linux-gnu'
        export BOINC_ALT_PLATFORM='--with-boinc-alt-platform=x86-android-linux-gnu'
        export BOINC_ARGS_EXTRA=''
        ;;
    'x86')
        export BOINC_PLATFORM='--with-boinc-platform=x86-android-linux-gnu'
        export BOINC_ALT_PLATFORM=''
        export BOINC_ARGS_EXTRA='--disable-largefile'
        ;;
    *)
        export BOINC_PLATFORM='--with-boinc-platform=unknown'
        export BOINC_ALT_PLATFORM='--with-boinc-alt-platform=unknown'
        export BOINC_ARGS_EXTRA=''
        ;;
esac

export BOINC_DEPS="--with-ssl=${OPENSSL_DIR}  --with-libcurl=${CURL_DIR} --with-sysroot=${SYSROOT}"
export BOINC_ARGS="--host=${TARGET} ${BOINC_PLATFORM} ${BOINC_ALT_PLATFORM} --disable-server --disable-manager --disable-shared --enable-static ${BOINC_DEPS} ${BOINC_ARGS_EXTRA}"
if [ -n "$BOINC_DEBUG" ]; then
    # Debug
    export BOINC_ARGS="${BOINC_ARGS} --enable-debug"
fi

# echo
if [ "$VERBOSE" = '1' ]; then
    grep '^export' set_env.sh | sed -e 's/    //g' | sed -e 's/grep.*//g' | sed -e 's/export //g' | sed -e 's/OLDPATH.*//g' | sed -e 's/PATH.*//g' | sed -e 's/=.*//g' | sort | uniq -u | sed -e 's/.*/echo &=$&/g' > env1
    if true; then # set true to ignore certain parts
        sed -i env1 -e 's/echo .*ARGS.*//g'
        sed -i env1 -e 's/echo ANDROID_NDK.*//g'
        sort env1 > env2
        uniq -u env2 env1
    fi
    sed -i env1 -e 's/echo =$.*//g'
    . ./env1 # SC1091
fi

# Check path
if [ ! -d "$NDK" ]; then
    echo 'ERROR: $NDK path does not exist!' # SC2016
fi
if [ ! -d "$TOOLCHAIN" ]; then
    echo 'ERROR: $TOOLCHAIN path does not exist!' # SC2016
fi
