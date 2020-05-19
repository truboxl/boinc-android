#!/bin/sh
set -e

if [ ! -d "$NDK" ]; then
    echo "NDK=${NDK}"
    echo 'Invalid path detected! curl build stopped!'
    exit 1
fi

if [ ! -d "$OPENSSL_DIR" ]; then
    echo "OPENSSL_DIR=${OPENSSL_DIR}"
    echo 'No OpenSSL directory detected! curl build may not have SSL support!'
fi

echo "===== curl ${CURL_VER:-unknown} build for ${TARGET} start ====="

if [ -n "$CURL_VER" ]; then
    cd "./src/curl-${CURL_VER}/"
else
    cd ./src/curl*/
fi

if [ -e ./Makefile ] && grep -q '^clean:' ./Makefile; then
    make clean -s
fi
if [ ! -e ./configure ]; then
    ./buildconf
fi
./configure ${CURL_ARGS} # SC2086
make
make install -s

echo "===== curl ${CURL_VER:-unknown} build for ${TARGET} done ====="
exit
