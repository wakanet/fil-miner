#!/bin/sh

a=$1
b=$2

./lotus.sh filplus grant-datacap --from $a $b 10240
