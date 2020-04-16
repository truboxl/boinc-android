#!/bin/sh
set -e

if [ ! -d "$ANDROID_NDK_ROOT" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT"
    echo "ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
    echo 'Invalid path detected! OpenSSL build stopped!'
    exit 1
fi

echo "===== OpenSSL build for android-$ARCH_SSL start ====="

cd ./openssl*/

if [ -e ./Makefile ] && $(grep -q '^clean:' ./Makefile); then
    make clean -s
fi
./Configure $OPENSSL_ARGS
make -s
make install_sw -s

echo "===== OpenSSL build for android-$ARCH_SSL done ====="
exit
