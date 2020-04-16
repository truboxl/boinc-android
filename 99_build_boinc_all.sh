#!/bin/sh
set -e

echo "===== BOINC build for all platforms start ====="

# aarch64
. ./unset_env.sh
NDK=$PWD/android-ndk-r21
ARCH=aarch64
API=21
. ./set_env.sh
./01_build_openssl.sh
./02_build_curl.sh
./03_build_boinc.sh

# arm
. ./unset_env.sh
NDK=$PWD/android-ndk-r21
ARCH=arm
API=19
. ./set_env.sh
./01_build_openssl.sh
./02_build_curl.sh
./03_build_boinc.sh

# x86_64
. ./unset_env.sh
NDK=$PWD/android-ndk-r21
ARCH=x86_64
API=21
. ./set_env.sh
./01_build_openssl.sh
./02_build_curl.sh
./03_build_boinc.sh

# x86
. ./unset_env.sh
NDK=$PWD/android-ndk-r21
ARCH=x86
API=19
. ./set_env.sh
./01_build_openssl.sh
./02_build_curl.sh
./03_build_boinc.sh

echo "===== BOINC build for all platforms done ====="
. ./unset_env.sh
exit
