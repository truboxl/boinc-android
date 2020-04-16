#!/bin/sh
set -e

if [ ! -d "$NDK" ]; then
    echo "NDK=$NDK"
    echo 'Invalid path detected! cURL build stopped!'
    exit 1
fi

if [ ! -d "$OPENSSL_DIR" ]; then
    echo "OPENSSL_DIR=$OPENSSL_DIR"
    echo 'No OpenSSL directory detected! cURL build may not have SSL support!'
fi

echo "===== cURL build for $TARGET start ====="

cd ./curl*/

if [ -e ./Makefile ] && $(grep -q '^clean:' ./Makefile) ; then
    make clean -s
fi
if [ ! -e ./configure ]; then
    ./buildconf
fi
./configure $CURL_ARGS
make -s
make install -s

echo "===== cURL build for $TARGET done ====="
exit
