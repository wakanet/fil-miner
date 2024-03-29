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
        curl -s -o $dealStage $fullUri 
    ;;
    "confirm"):
        propCid=$2
        fullUri=$3
        fileName=$4
        dealStage=$5
        echo "confirm: $propCid,$fullUri,$fileName,$dealStage"
        curl -s -d "propCid=$propCid&remoteUrl=$fullUri" "http://127.0.0.1:9080/deal/confirm"
    ;;
    *)
        echo "TODO"
    ;;
esac
