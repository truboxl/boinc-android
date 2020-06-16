#!/bin/sh
set -e

if [ ! -d "$NDK" ]; then
    echo "NDK=${NDK}"
    echo 'Invalid path detected! BOINC build stopped!'
    exit 1
fi

if [ ! -d "$OPENSSL_DIR" ]; then
    echo "OPENSSL_DIR=${OPENSSL_DIR}"
    echo 'No OpenSSL directory detected! BOINC build may not have SSL support!'
fi

if [ ! -x "${CURL_DIR}/bin/curl-config" ]; then
    echo "CURL_DIR=${CURL_DIR}"
    echo 'curl-config may be invalid or not executable! BOINC build may fail!'
fi

if [ -z "$STRIP" ]; then
    echo "STRIP=${STRIP}"
    echo 'Invalid path detected! BOINC build may fail!'
fi

echo "===== BOINC ${BOINC_VER:-unknown} build for ${TARGET} (${ABI}) start ====="

if [ -n "$BOINC_VER" ]; then
    cd "./src/boinc-${BOINC_VER}/"
else
    cd ./src/boinc*/
fi

export BOINC="$PWD"

if [ -e ./Makefile ] && grep -q '^distclean:' ./Makefile; then
    make distclean -s
fi

# Unfortunately BOINC ./configure is not intelligent in setting FLAGS for Android
export CFLAGS='-DANDROID -DDECLARE_TIMEZONE'
export CXXFLAGS='-DANDROID -DDECLARE_TIMEZONE'
if [ -z "$BOINC_DEBUG" ]; then
    # Release
    export CFLAGS="${CFLAGS} -O3"
    export CXXFLAGS="${CXXFLAGS} -O3"
else
    # Debug
    export CFLAGS="${CFLAGS} -O1"
    export CXXFLAGS="${CXXFLAGS} -O1"
fi
export LDFLAGS="-llog -latomic -static-libstdc++ -L${OPENSSL_DIR}/lib"

./_autosetup
./configure ${BOINC_ARGS} --prefix=/usr/local # SC2086
make -s
make stage -s

if [ -z "$BOINC_DEBUG" ]; then
    # Release
    echo 'Stripping binaries'
    cd "${BOINC}/stage/usr/local/bin"
    "$STRIP" ./*
fi

echo 'Copying assets'
cd "${BOINC}/android"
mkdir -p "BOINC/app/src/main/assets/${ABI}/"
cp -f "${BOINC}/stage/usr/local/bin/boinc" "BOINC/app/src/main/assets/${ABI}/boinc"
cp -f "${BOINC}/win_build/installerv2/redist/all_projects_list.xml" "BOINC/app/src/main/assets/all_projects_list.xml"
cp -f "${BOINC}/curl/ca-bundle.crt" "BOINC/app/src/main/assets/ca-bundle.crt"

echo "===== BOINC ${BOINC_VER:-unknown} build for ${TARGET} (${ABI}) done ====="
