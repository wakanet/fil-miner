#!/bin/sh

# REAME
# this is a debug for pb-storage. on the production need to replace this

case $1 in
    "fetch")
        echo "fetch: $2 $3 $4"
        curl -o $4 $3
    ;;
    "confirm"):
        echo "confirm: $2 $3"
    ;;
    *)
        echo "TODO"
    ;;
esac
