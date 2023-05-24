#!/bin/sh

minerAddr=$1
clientAddr=$2
duration=$3
storageId=$4
httpServer=$5

if [ -z "$minerAddr" ]; then
    echo "minerAddr(arg1) not set"
    exit
fi

if [ -z "$clientAddr" ]; then
    echo "clientAddr(arg2) not set"
    exit
fi
if [ -z "$duration" ]; then
    echo "duration(arg3) not set"
    exit
fi
if [ -z "$storageId" ]; then
    echo "storageId(arg4) not set"
    exit
fi
if [ -z "$httpServer" ]; then
    echo "httpServer(arg5) not set"
    exit
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
    propose_out=$(curl -s -d "minerAddr=$minerAddr&clientAddr=$clientAddr&epochDur=$duration" "$httpServer/deal/propose")
    propCid=$(echo $propose_out|/usr/bin/jq .ProposeCid|sed 's/\"//g')
    rootCid=$(echo $propose_out|/usr/bin/jq .RootCid|sed 's/\"//g')
    pieceCid=$(echo $propose_out|/usr/bin/jq .PieceCid|sed 's/\"//g')
    pieceSize=$(echo $propose_out|/usr/bin/jq .PieceSize|sed 's/\"//g')
    remoteUrl=$(echo $propose_out|/usr/bin/jq .RemoteUrl|sed 's/\"//g')
    
    echo "ID:$ID,propCid:$propCid,rootCid:$rootCid,pieceCid:$pieceCid,pieceSize:$pieceSize,clientAddr:$clientAddr,car:$remoteUrlPath"

    echo "make propose, idle:$idle,limit:$apLimit,disk:$diskUsed"
    echo $(date --rfc-3339=ns)
    if [ -z "$propCid" ]; then
      echo "cid not found: $propose_out"
      exit
    fi
    
    output=$(./miner.sh fstar-market new-fstmp --really-do-it)
    filename=$(basename $output)
    touch $output # make a empty fsmtp
    
    echo "record-deal:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh fstar-market record-deal $propCid $rootCid $pieceCid $pieceSize $clientAddr $output $remoteUrl $storageId
    if [ $? -ne 0 ]; then
      echo "record failed: $propose_out"
      continue
    fi
    
    echo "import-data:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh storage-deals import-data --storage-id=$storageId $propCid $output $remoteUrl
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      continue
    fi
done
