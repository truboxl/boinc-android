#!/bin/sh
set -e
echo '===== Build cache clean start ====='
rm -rf "${PWD}"/env*
rm -rf "${PWD}"/buildcache/
echo '===== Build cache clean done ====='
