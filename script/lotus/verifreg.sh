#!/bin/sh

verifer=$1

if [ -z $verifer ]; then
    echo "no verifer set"
    exit
fi

./shed.sh verifreg add-verifier t14po2vrupy7buror4g55c7shlcrmwsjxbpss7dzy $verifer 1024000

