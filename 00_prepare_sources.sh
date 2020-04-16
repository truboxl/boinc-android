#!/bin/sh
echo '===== Prepare sources start ====='

echo 'Preparing OpenSSL sources'
#git clone 'https://github.com/openssl/openssl' # OpenSSL 3 is broken for Android
curl -#OC - 'https://www.openssl.org/source/openssl-1.1.1f.tar.gz'
tar xf openssl-1.1.1f.tar.gz

echo 'Preparing cURL sources'
#git clone 'https://github.com/curl/curl'
curl -#OC - 'https://curl.haxx.se/download/curl-7.69.1.tar.xz'
tar xf curl-7.69.1.tar.xz

echo 'Preparing BOINC sources'
git clone 'https://github.com/boinc/boinc'
# BOINC Android is moving fast in master

echo 'Preparing Android NDK'
# If you have already downloaded Android NDK
# please edit $NDK at ./99_build_boinc_all.sh
# and comment the lines here

case "`uname`" in

    'Linux')
        HOST_TAG='linux-x86_64'
        ;;
    MSYS*)
        HOST_TAG='windows-x86_64'
        ;;
    Darwin*)
        HOST_TAG='darwin-x86_64'
        ;;

esac

curl -#OC - "https://dl.google.com/android/repository/android-ndk-r21-$HOST_TAG.zip"
unzip -q "android-ndk-r21-$HOST_TAG.zip"

# EXPERIMENTAL BUILD ON WINDOWS
# Please don't go into the deep rabbit hole of building on Windows
# You will be dealing with:
# * clang and "C:\" instead of "/" on cmd.exe and cygwin
# * lot's of weird issues that weren't present on true Linux environment
# * slow compiling (even with MAKEFLAGS='-j2')
# Use VM or WSL instead
# Use msys2 if you really want to fix issues
# TODO: Broken at building for arm

echo '===== Prepare sources done ====='
exit
