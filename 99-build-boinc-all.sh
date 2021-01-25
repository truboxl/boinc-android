#!/bin/sh
set -e

# temporarily set the API version here, defaults are:
#API64=21
#API32=16
API64=21
API32=16

build() {
    ./01-build-openssl.sh
    ./02-build-curl.sh
    ./03-build-boinc.sh
}

normalbuild() {
    for hostarch in aarch64 x86_64; do
        . ./unset-env.sh
        ARCH="$hostarch"
        API="$API64"
        . ./set-env.sh
        build
    done

    for hostarch in arm x86; do
        . ./unset-env.sh
        ARCH="$hostarch"
        API="$API32"
        . ./set-env.sh
        build
    done
}

# Experimental, theoretically faster
pipelinebuild() {

    RST='\033[0m'
    YLW='\033[0;33mBuilding'

    # T+1
    . ./unset-env.sh
    ARCH=aarch64
    API="$API64"
    . ./set-env.sh
    ./01-build-openssl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+2
    . ./unset-env.sh
    ARCH=aarch64
    API="$API64"
    . ./set-env.sh
    ./02-build-curl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset-env.sh
    ARCH=x86_64
    API="$API64"
    . ./set-env.sh
    ./01-build-openssl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+3
    . ./unset-env.sh
    ARCH=aarch64
    API="$API64"
    . ./set-env.sh
    ./03-build-boinc.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset-env.sh
    ARCH=x86_64
    API="$API64"
    . ./set-env.sh
    ./02-build-curl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset-env.sh
    ARCH=arm
    API="$API32"
    . ./set-env.sh
    ./01-build-openssl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+4
    . ./unset-env.sh
    ARCH=x86_64
    API="$API64"
    . ./set-env.sh
    ./03-build-boinc.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset-env.sh
    ARCH=arm
    API="$API32"
    . ./set-env.sh
    ./02-build-curl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset-env.sh
    ARCH=x86
    API="$API32"
    . ./set-env.sh
    ./01-build-openssl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+5
    . ./unset-env.sh
    ARCH=arm
    API="$API32"
    . ./set-env.sh
    ./03-build-boinc.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset-env.sh
    ARCH=x86
    API="$API32"
    . ./set-env.sh
    ./02-build-curl.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"
    wait

    # T+6
    . ./unset-env.sh
    ARCH=x86
    API="$API32"
    . ./set-env.sh
    ./03-build-boinc.sh 2>/dev/null >/dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"
    wait
}

echo '===== BOINC build for all platforms start ====='

if [ "$1" != 'pipeline' ]; then
    normalbuild
else
    echo 'WARN: Building in pipeline (Experimental)'
    echo "WARN: Using MAKEFLAGS=${MAKEFLAGS:--j2}"
    echo 'WARN: A maximum of 3x the number of threads above will be used'
    pipelinebuild
fi

echo '===== BOINC build for all platforms done ====='
. ./unset-env.sh

echo 'If you are cross compiling on WSL, copy the binaries from'
echo 'src/boinc*/android/BOINC/app/src/main/assets'
echo 'to your directory that can be accessible by Android Studio'
