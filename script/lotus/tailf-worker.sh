#!/bin/sh

kind=$1
if [ -z "$kind" ]; then
  kind="stderr"
fi
fild ctl tail -f lotus-worker-1 $kind
