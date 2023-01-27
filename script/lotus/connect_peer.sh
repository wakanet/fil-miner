#!/bin/sh

sleep_time=7200

echo $(date --rfc-3339=ns)
./lotus.sh net connect --bootstrap
echo $(date --rfc-3339=ns)
./lotus.sh net connect --score-peers=50
echo $(date --rfc-3339=ns)
echo "sleep $sleep_time"
sleep $sleep_time
