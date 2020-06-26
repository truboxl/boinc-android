#!/bin/sh
# This file should be sourced and not executed
# Default of this script is ARCH=aarch64; API=21 but can be overriden

# Sources version
export OPENSSL_VER=1.1.1g
export CURL_VER=7.69.1
export NDK_VER=r21d

# make
export MAKEFLAGS="${MAKEFLAGS:--j2}"

##### Android NDK #####
# https://developer.android.com/ndk/guides/other_build_systems
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md
export NDK="${NDK:-${PWD}/src/android-ndk-${NDK_VER}}"

# NDK OS Variant  Host Tag
# macOS           darwin-x86_64
# Linux           linux-x86_64
# 32-bit Windows  windows
# 64-bit Windows  windows-x86_64
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

# Name          arch     ABI          triple
# 32-bit ARMv7  arm      armeabi-v7a  arm-linux-androideabi
# 64-bit ARMv8  aarch64  arm64-v8a    aarch64-linux-android
# 32-bit Intel  x86      x86          i686-linux-android
# 64-bit Intel  x86_64   x86_64       x86_64-linux-android
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
# API  Version  Notes
# 23   6.0      fix stderr stdin stdout undefined in OpenSSL / curl
# 21   5.0      support 64bit / mandate PIE
# 19   4.4      fix sys/swap.h
# 16   4.1      lowest version to run PIE
export API="${API:-21}"

# Set NDK variables
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
export SYSROOT="${TOOLCHAIN}/sysroot" # no longer needed for newer NDK

# arm vfpv3-d16 fix (disable NEON)
if [ "$ARCH" = 'arm' ]; then
    export CFLAGS="${CFLAGS} -mfloat-abi=softfp -mfpu=vfpv3-d16"
    export CXXFLAGS="${CXXFLAGS} -mfloat-abi=softfp -mfpu=vfpv3-d16"
fi

# Set optimization level
if [ -z "$APP_DEBUG" ]; then
    # Release
    export CFLAGS="${CFLAGS} -Os"
    export CXXFLAGS="${CXXFLAGS} -Os"
else
    # Debug
    export CFLAGS="${CFLAGS} -O1"
    export CXXFLAGS="${CXXFLAGS} -O1"
fi

##### OpenSSL #####
# openssl/NOTES.ANDROID
export ANDROID_NDK_ROOT="$NDK" # Used by OpenSSL 3, currently broken
export ANDROID_NDK_HOME="$NDK" # Used by OpenSSL 1.1
export OPENSSL_DIR="${PWD}/buildcache/ssl-${ARCH}-${API}"
if [ "$ARCH" = 'aarch64' ]; then
    export ARCH_SSL='arm64'
else
    export ARCH_SSL="$ARCH"
fi
export OPENSSL_ARGS="android-${ARCH_SSL} no-shared no-dso -D__ANDROID_API__=${API} --prefix=${OPENSSL_DIR} --openssldir=${OPENSSL_DIR}"

##### curl #####
# curl/INSTALL.md
export CURL_DIR="${PWD}/buildcache/curl-${ARCH}-${API}"
export CURL_ARGS="--host=${TARGET} --with-pic --disable-shared --with-ssl=${OPENSSL_DIR} --with-sysroot=${SYSROOT} --prefix=${CURL_DIR}"

##### BOINC #####
# https://boinc.berkeley.edu/trac/wiki/BuildSystem
case "$ARCH" in
    arm|x86)
        export BOINC_ARGS_EXTRA='--disable-largefile'
        ;;
esac
export BOINC_DEPS="--with-ssl=${OPENSSL_DIR}  --with-libcurl=${CURL_DIR} --with-sysroot=${SYSROOT}"
export BOINC_ARGS="--host=${TARGET} --disable-server --disable-manager --disable-shared ${BOINC_DEPS} ${BOINC_ARGS_EXTRA}"
if [ -n "$APP_DEBUG" ]; then
    # Debug
    export BOINC_ARGS="${BOINC_ARGS} --enable-debug"
fi

##### Script logging #####
# echo
if [ "$VERBOSE" = '1' ]; then
    grep 'export ' set_env.sh | sed -e 's/    //g' | sed -e 's/grep.*//g' | sed -e 's/export //g' | sed -e 's/OLDPATH.*//g' | sed -e 's/PATH.*//g' | sed -e 's/=.*//g' | sort | uniq -u | sed -e 's/.*/echo &=$&/g' > env1
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
