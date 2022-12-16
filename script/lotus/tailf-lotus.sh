#!/bin/sh

kind=$1
if [ -z "$kind" ]; then
  kind="stderr"
fi

name="lotus-daemon-1"
case $lotusrepo in
    "/data/cache/.lotus")
        name="lotus-daemon-1"
    ;;
    "/data/cache/.lotus2")
        name="lotus-daemon-2"
    ;;
    "/data/cache/.lotus3")
        name="lotus-daemon-3"
    ;;
esac

filc tail -f $name $kind
