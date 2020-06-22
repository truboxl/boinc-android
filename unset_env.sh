#!/bin/sh
# This file should be sourced and not executed

# Unset PATH is not safe
if [ -n "$OLDPATH" ]; then
    export PATH="$OLDPATH"
fi

grep 'export ' set_env.sh | sed -e 's/    //g' | sed -e 's/grep.*//g' | sed -e 's/export /unset /g' | sed -e 's/unset PATH.*//g' | sed -e 's/=.*//g' | sort | uniq | uniq -u > env1
. ./env1 # SC1091

# echo
if [ "$VERBOSE" = '1' ]; then
    paste env1 | sed -e 's/unset //g' | sed -e 's/.*/echo &=$&/g' | sed -e 's/echo =$.*//g' > env2
    . ./env2 # SC1091
fi
