#!/bin/sh

client_addr=$1
input_file=$2
cache_dir="/data/cache/dc-tmp"
sleep_sec=10

mkdir -p $cache_dir

call_sleep(){
  echo "sleep "$sleep_sec
  sleep $sleep_sec
}

if [ -z "$client_addr" ]; then
    echo "client address not set, expect [client addr] [file source]"
    exit
fi

if [ -z "$input_file" ]; then
    echo "input file not set, expect [client addr] [file source]"
    exit
fi

#./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --min-piece-size 1B --max-piece-size 2KiB
files=$(cat /tmp/files.txt)
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
    mv $filePath $output
    if [ $? -ne 0 ]; then
      echo "rename failed: $propose_out"
      exit
    fi

    echo "record-deal:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh fstar-market record-deal $propCid $rootCid $pieceCid $pieceSize $client_addr $output
    if [ $? -ne 0 ]; then
      echo "record failed: $propose_out"
      exit
    fi
    
    echo "import-data:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh storage-deals import-data $propCid $output
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      exit
    fi
    echo "end"
done

./miner.sh storage-deals pending-publish --publish-now
ls -lt /data/sdb/lotus-user-1/.lotusminer/deal-staging
