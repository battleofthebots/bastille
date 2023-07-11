#!/bin/bash

###
### This script will build a jail in the current directory and then run bastille in the jail
### Usage:
###    bash build_jail.sh [jail]
###    cd cwd && PATH=<jail> ./bastille

[ "$JAIL_BIN" = "" ] && export JAIL_BIN=bin
[ "$JAIL_CWD" = "" ] && export JAIL_CWD=cwd
ALLOWED="echo awk rm tee bind mkdir xxd strings pwd ls fmt file dd bc make cp whoami su cat"

mkdir -pv $JAIL_BIN $JAIL_CWD

for i in $ALLOWED; do
    [ "$(which $i 2>/dev/null)" != "" ] && cp -v $(which $i) $JAIL_BIN/$i;
done

chmod 555 $JAIL_BIN
chmod 777 $JAIL_CWD

echo -e "Run the following command to goto jail:\n\tPATH=$JAIL_BIN ./bastille"