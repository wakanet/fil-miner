#!/bin/sh

# REAME
# this is a debug for pb-storage. on the production need to replace this

case $1 in
    "fetch")
        propCid=$2
        fullUri=$3
        fileName=$4
        dealStage=$5
        echo "fetch: $propCid,$fullUri,$fileName,$dealStage"
        curl -o $fullUri $dealStage
    ;;
    "confirm"):
        echo "confirm: $2 $3"
    ;;
    *)
        echo "TODO"
    ;;
esac
