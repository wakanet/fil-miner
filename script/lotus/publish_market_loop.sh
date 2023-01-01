#!/bin/sh

while true
do
  echo $(date --rfc-3339=ns)
  ./miner.sh storage-deals pending-publish --publish-now
  echo "sleep 600"
  sleep 600
done
