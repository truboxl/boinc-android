#!/bin/sh
set -e
echo '===== Build cache clean start ====='
echo 'Cleaning env'
rm -fr ${PWD}/env*

echo 'Cleaning buildcache'
rm -fr ${PWD}/buildcache/

echo 'Cleaning openssl'
rm -fr ${PWD}/src/openssl*/

echo 'Cleaning curl'
rm -fr ${PWD}/src/curl*/

if [ -d ${PWD}/src/boinc/ ]; then
    echo 'Cleaning boinc'
    cd ${PWD}/src/boinc/
    git clean -fxdq
fi
echo '===== Build cache clean done ====='
