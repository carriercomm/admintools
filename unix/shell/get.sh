#!/usr/bin/env bash

# os: bsd
# version: 1.0
# purpose: extracts tgz to ~/[selection] using @arg0 in case
# requires: tar

selection="[bnc|psybnc|eggdrop|emech|ezbounce]";
tgz_location="/home/.common/tgz"

if [ ! $1 ]; then
    echo "USAGE: $0 $selection" 2>&1;
    exit 1;
fi

case "$1" in
    "bnc" )
        what="bnc2.9*tar.gz";
    ;;
    "psybnc" )
        what="psybnc*tgz";
    ;;
    "eggdrop" )
        what="eggdrop*tar.gz";
    ;;
    "emech" )
        what="emech*tar.gz";
    ;;
    "ezbounce" )
        what="ezbounce*tar.gz";
    ;;

    * )
        echo "ERROR: Invalid Selection - $selection available" 2>&1;
        exit 1;
    ;;
esac

if [ $what ]; then
    echo "Extracting $what to $HOME...";
    sleep 2;
    tar -zxvf $tgz_location/$what -C ~
    echo "Done! Exiting...";
fi
exit 0;
