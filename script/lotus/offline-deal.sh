#!/bin/sh

client_addr=$1
input_file=$2
storage_id=$3
cache_dir="/data/cache/dc-tmp"
sleep_sec=10
local_ip="`/bin/sh $PRJ_ROOT/bin/ip.sh`"

if [ -z "$storage_id" ]; then
    storage_id=0
fi

mkdir -p $cache_dir

call_sleep(){
  echo "sleep "$sleep_sec
  sleep $sleep_sec
}

if [ -z "$client_addr" ]; then
    echo "client address not set, expect [client addr] [file source] [<storage_id>]"
    exit
fi

if [ -z "$input_file" ]; then
    echo "input file not set, expect [client addr] [file source] [<storage_id>]"
    exit
fi

#./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --max-piece-size 2KiB
files=$(cat $input_file)
for f in $files
do
    echo "make propose"
	echo $(date --rfc-3339=ns)
    propose_out=$(./miner.sh fstar-market make-deal --from $client_addr --src-max-size=2048 --pack-interval=3 --duration=518400 --cache-dir="/data/cache/dc-tmp" $f)
	propCid=$(echo $propose_out|/usr/bin/jq '.PropCid'|sed 's/\"//g')
	rootCid=$(echo $propose_out|/usr/bin/jq '.Params.Data.Root."/"'|sed 's/\"//g')
	pieceCid=$(echo $propose_out|/usr/bin/jq '.Params.Data.PieceCid."/"'|sed 's/\"//g')
    pieceSize=$(echo $propose_out|/usr/bin/jq '.Params.Data.PieceSize'|sed 's/\"//g')
    filePath=$(echo $propose_out|/usr/bin/jq '.Path'|sed 's/\"//g')
    if [ -z "$propCid" ]; then
      echo "cid not found: $propose_out"
      exit
    fi

	output=$(./miner.sh fstar-market new-fstmp --really-do-it)
    filename=$(basename $output)
    remoteUri="http://$local_ip:2356/deal-staging/$filename"
    touch $output # make a empty fsmtp
    #sudo mv $filePath $output # mv to where is need
    case $storage_id in
        0)
            debugPath="/data/sdb/lotus-user-1/.lotusminer/deal-staging"
        ;;
        1)
            debugPath="/data/nfs/lotus-user-1/1/deal-staging"
        ;;
        *)
            debugPath="/data/sdb/lotus-user-2/.lotusminer/deal-staging" # using the pb-storage
        ;;
    esac
    sudo mv $filePath $debugPath/$filename # mv to where is need
    ls -lat $debugPath
    if [ $? -ne 0 ]; then
      echo "rename failed: $propose_out"
      exit
    fi

    echo "record-deal:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh fstar-market record-deal $propCid $rootCid $pieceCid $pieceSize $client_addr $output $remoteUri $storage_id
    if [ $? -ne 0 ]; then
      echo "record failed: $propose_out"
      exit
    fi
    
    echo "import-data:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh storage-deals import-data --storage-id=$storage_id $propCid $output $remoteUri
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      exit
    fi
    echo "end"
done

./miner.sh storage-deals pending-publish --publish-now
ls -lt /data/sdb/lotus-user-1/.lotusminer/deal-staging/
