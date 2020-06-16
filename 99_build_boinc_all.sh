#!/bin/sh
set -e

API64=21
API32=19

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
    # T+1
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo 'Building aarch64 openssl'
    wait

    # T+2
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo 'Building aarch64 curl'

    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo 'Building x86_64 openssl'
    wait

    # T+3
    . ./unset_env.sh
    ARCH=aarch64
    API="$API64"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo 'Building aarch64 boinc'

    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo 'Building x86_64 curl'

    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo 'Building arm openssl'
    wait

    # T+4
    . ./unset_env.sh
    ARCH=x86_64
    API="$API64"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo 'Building x86_64 boinc'

    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo 'Building arm curl'

    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./01_build_openssl.sh 2>&1 > /dev/null &
    echo 'Building x86 openssl'
    wait

    # T+5
    . ./unset_env.sh
    ARCH=arm
    API="$API32"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo 'Building arm boinc'

    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./02_build_curl.sh 2>&1 > /dev/null &
    echo 'Building x86 curl'
    wait

    # T+6
    . ./unset_env.sh
    ARCH=x86
    API="$API32"
    . ./set_env.sh
    ./03_build_boinc.sh 2>&1 > /dev/null &
    echo 'Building x86 boinc'
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
