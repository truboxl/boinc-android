#!/bin/sh
# Optional feature patches for BOINC

if [ ! -d ./patch ]; then
    git clone 'https://github.com/truboxl/boinc-feature-patch' ./patch || exit 1
fi

LINE_NO="$(grep 'Instructions' ./patch/README.md -n | sed -e 's/:### Instructions//')"
tail -n "+$LINE_NO" ./patch/README.md
