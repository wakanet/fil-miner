#!/bin/sh

# import csv
# .separator ","
# .import ./task.csv market_task

storage_id=$1
if [ -z $storage_id ]; then
    storage_id=1
fi

sleep_sec=10
call_sleep(){
  echo "sleep "$sleep_sec
  sleep $sleep_sec
}

while true
do
    echo $(date --rfc-3339=ns)
    call_sleep

    idle=$(./miner.sh fstar-worker producer-idle)
    isIdle=$(echo "$idle"|sed -n "/^[0-9][0-9]*$/p")
    apLimit=$(./miner.sh pledge-sector get-limit-ap-cur)
    isAPLimit=$(echo "$apLimit"|sed -n "/^[0-9][0-9]*$/p")
    diskUsed=$(df /data --output=pcent|sed '1d'|sed 's/%//g'|awk '{printf $1}')

    if [ -z "$isIdle" ];then
            echo "idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
            continue
    fi
    if [ $diskUsed -gt 97 ]; then
            echo "disk failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
            continue
    fi
    if [ -z "$isAPLimit" ];then
            echo "ap limit not a number, idle:$idle,limit:$apLimit,disk:$diskUsed"
            continue
    fi
    idleLimit=$(expr $apLimit - $idle)
    if [ $idleLimit -gt 200 ]; then
            echo "apLimit more then the idles, idle:$idle,limit:$apLimit,disk:$diskUsed"
            continue
    fi

    # fetch data
    ID=$(echo "SELECT ID FROM market_task WHERE State=0 LIMIT 1"|sqlite3 task.db)
    if [ -z "$ID" ]; then
      echo "no data"
      continue
    fi
    propCid=$(echo "SELECT UUID FROM market_task WHERE ID=$ID"|sqlite3 task.db)
    rootCid=$(echo "SELECT PayloadCid FROM market_task WHERE ID=$ID"|sqlite3 task.db)
    pieceCid=$(echo "SELECT PieceCID FROM market_task WHERE ID=$ID"|sqlite3 task.db)
    pieceSize=$(echo "SELECT PieceSize FROM market_task WHERE ID=$ID"|sqlite3 task.db)
    clientAddr=$(echo "SELECT Client FROM market_task WHERE ID=$ID"|sqlite3 task.db)
    filePath=$pieceCid".car"
    
    echo "ID:$ID,propCid:$propCid,rootCid:$rootCid,pieceCid:$pieceCid,pieceSize:$pieceSize,clientAddr:$clientAddr,car:$filePath"
    echo "UPDATE market_task SET State=1 WHERE ID=$ID"|sqlite3 task.db

    echo "make propose, idle:$idle,limit:$apLimit,disk:$diskUsed"
    echo $(date --rfc-3339=ns)
    if [ -z "$propCid" ]; then
      echo "cid not found: $propose_out"
      exit
    fi
    
    output=$(./miner.sh fstar-market new-fstmp --really-do-it)
    filename=$(basename $output)
    remoteUri=$filePath
    touch $output # make a empty fsmtp
    
    echo "record-deal:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh fstar-market record-deal $propCid $rootCid $pieceCid $pieceSize $clientAddr $output $remoteUri $storage_id
    if [ $? -ne 0 ]; then
      echo "record failed: $propose_out"
      continue
    fi
    
    echo "import-data:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh storage-deals import-data --storage-id=$storage_id $propCid $output $remoteUri
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      continue
    fi
    echo "end"
done
