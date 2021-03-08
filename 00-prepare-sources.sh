#!/bin/sh
# get the version from one source
. ./set-env.sh

echo '===== Prepare sources start ====='
mkdir -p "${PWD}/src/"
cd "${PWD}/src/" || exit 1

echo "Preparing OpenSSL ${OPENSSL_VER} sources"
#git clone 'https://github.com/openssl/openssl' # OpenSSL 3 is broken for Android
curl -#LOC - "https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz"
tar xf "openssl-${OPENSSL_VER}.tar.gz"

echo "Preparing curl ${CURL_VER} sources"
#git clone 'https://github.com/curl/curl'
curl -#LOC - "https://curl.haxx.se/download/curl-${CURL_VER}.tar.xz"
tar xf "curl-${CURL_VER}.tar.xz"

echo "Preparing Android NDK ${NDK_VER}"
case "$(uname)" in
Linux)
    HOST_TAG='linux-x86_64'
    ;;
Darwin)
    HOST_TAG='darwin-x86_64'
    ;;
MSYS*|MINGW*)
    HOST_TAG='windows-x86_64'
    ;;
*)
    HOST_TAG='linux-x86_64'
    ;;
esac

# if you have already downloaded Android NDK
# please edit $NDK at ./set-env.sh and comment the lines here
curl -#LOC - "https://dl.google.com/android/repository/android-ndk-${NDK_VER}-${HOST_TAG}.zip"
unzip -oq "android-ndk-${NDK_VER}-${HOST_TAG}.zip"

# EXPERIMENTAL BUILD ON WINDOWS
# please don't go into the deep rabbit hole of building on Windows
# you will be dealing with:
# * clang using "C:\" instead of "/" under cmd.exe and cygwin
# * some command offered with extension .exe, .cmd, or none at all
# * hitting the command length limit: https://devblogs.microsoft.com/oldnewthing/20031210-00/?p=41553
# * lot's of weird issues that weren't present on true Linux environment
# * slow compiling (even with MAKEFLAGS='-j2')
# use VM or WSL instead
# use msys2 if you really want to fix issues

echo 'Preparing BOINC sources'
# BOINC Android is moving fast in master
# during build, BOINC unknown will be shown
if [ -d ./boinc ]; then
    echo 'BOINC repo seems to be available, moving on'
else
    git clone 'https://github.com/boinc/boinc' || exit 1
fi

echo '===== Prepare sources done ====='
cd ..
. ./unset-env.sh
