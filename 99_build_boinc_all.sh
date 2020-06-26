#!/bin/sh
set -e

API64=21
API32=16

build() {
    ./01_build_openssl.sh
    ./02_build_curl.sh
    ./03_build_boinc.sh
}

normalbuild() {
    for hostarch in aarch64 x86_64; do
        . ./unset_env.sh
        ARCH="$hostarch"
        API="$API64"
        . ./set_env.sh
        build
    done

    for hostarch in arm x86; do
        . ./unset_env.sh
        ARCH="$hostarch"
        API="$API32"
        . ./set_env.sh
        build
    done
}

# Experimental, theoretically faster
pipelinebuild() {

    RST='\033[0m'
    YLW='\033[0;33mBuilding'

    # T+1
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+2
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+3
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+4
    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"

    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} openssl${RST}"
    wait

    # T+5
    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"

    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} curl${RST}"
    wait

    # T+6
    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo -e "${YLW} ${ARCH} boinc${RST}"
    wait
}

echo '===== BOINC build for all platforms start ====='

if [ "$1" != 'pipeline' ]; then
    normalbuild
else
    echo 'Experimental: Building in pipeline'
    echo 'Expect console output mess'
    pipelinebuild
fi

echo '===== BOINC build for all platforms done ====='
. ./unset_env.sh
