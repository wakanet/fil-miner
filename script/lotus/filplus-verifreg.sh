#!/bin/sh

verifer=$1

if [ -z $verifer ]; then
    echo "no verifer set"
    exit
fi

if [ -z "$lotusrepo" ]; then
    echo "Not found env 'lotusrepo'"
    exit 0
fi

sh -x ./shed.sh verifreg --repo=$lotusrepo add-verifier t14po2vrupy7buror4g55c7shlcrmwsjxbpss7dzy $verifer 1024000

