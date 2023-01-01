#!/bin/sh

while true
do
  echo $(date --rfc-3339=ns)
  ./miner.sh sectors batching precommit --publish-now
  ./miner.sh sectors batching commit --publish-now
  echo "sleep 600"
  sleep 600
done
