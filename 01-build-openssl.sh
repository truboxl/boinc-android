#!/bin/sh
set -e

if [ ! -d "$ANDROID_NDK_ROOT" ] && [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}" # OpenSSL 3
    echo "ANDROID_NDK_HOME=${ANDROID_NDK_HOME}" # OpenSSL 1.1.1
    echo 'Invalid path detected! OpenSSL build stopped!'
    exit 1
fi

echo "===== OpenSSL ${OPENSSL_VER:-unknown} build for android-${ARCH_SSL} start ====="

if [ -n "$OPENSSL_VER" ]; then
    cd "./src/openssl-${OPENSSL_VER}/"
else
    cd ./src/openssl*/
fi

if [ -e ./Makefile ] && grep -q '^clean:' ./Makefile; then
    make clean -s
fi
./Configure ${OPENSSL_ARGS} # SC2086
make -s
make install_sw -s

echo "===== OpenSSL ${OPENSSL_VER:-unknown} build for android-${ARCH_SSL} done ====="
