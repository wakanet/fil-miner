## WorkerSpace
the root dir default is './' , the release is '/data/lotus-datacap'
```
src-dir/src -- the source file directory. BE CAREFUL, it will auto remove file by the program
src-dir/cache -- the packing cache directory, it will fetch data from src-dir
src-dir/src.lock -- src download lock file, can't pack when value is '1'
tar-dir/pack -- the packing result directory, it will remove the file after pack.
tar-dir/cache -- the tar file swapping directory, it will remove the file after swapped.
car-dir -- the car file directory, it generate car from tar-dir, and remove the cache-dir file when done. and support the car file for download.
sqlite.db -- the api server database, it record the download transcation.
```

## Deployment
```shell
lotus-datacap pack-srv # run then pack service to packing src files
lotus-datacap car-srv # run the car service to gen car files and support car api service

touch /data/lotus-datacap/src-dir/src/src.lock

# lock
echo -ne "1" > /data/lotus-datacap/src-dir/src/src.lock # lock the src dir when download data by manually

# download files or directory to /data/lotus-datacap/src-dir/src

# unlock
echo -ne "0" > /data/lotus-datacap/src-dir/src/src.lock # after unlock the src.lock, the pack-srv and car-srv will auto run.

# SPEC for restart car-srv:
# restart car-srv
# stop the car-srv
# mv /data/lotus-datacap/tar-dir/cache/* /data/lotus-datacap/tar-dir/pack
# start car-srv

```

## Client API

### make propose
Request
```
Uri: /deal/propose
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form: 
transfer-type=manual # only support manual type current
minerAddr=f01001 # miner id for deal propose
clientAddr=t1xxx # client address
```

Response(code 200)
```
Content-Type: application/json
Body:
{
  "ProposalCid":"",
  "RootCid":"",
  "PieceCid":"",
  "PieceSize":"",
  "RemoteUrl":"", // the download url
}
```

Response(code not 200)
```
Content-Type: text/plain
Body:
the message
```

Example
```shell
aptitude install jq

propose_out=$(`curl -s -d "transfer-type=manual&minerAddr=t01004&clientAddr=t1xxx&epochDur=1575360" http://127.0.0.1:9080/deal/propose`)
propCid=$(echo $propose_out|/usr/bin/jq .ProposalCid|sed 's/\"//g')
rootCid=$(echo $propose_out|/usr/bin/jq .RootCid|sed 's/\"//g')
pieceCid=$(echo $propose_out|/usr/bin/jq .PieceCid|sed 's/\"//g')
pieceSize=$(echo $propose_out|/usr/bin/jq .PieceSize|sed 's/\"//g')
remoteUrl=$(echo $propose_out|/usr/bin/jq .RemoteUrl|sed 's/\"//g')
if [ -z "$propCid" ]; then
  echo "cid not found: $propose_out"
  exit
fi
```


### Car file download
Request
```
Uri: /uuid.car
Method: GET
BasicAuth: md5(ak-id)
```
Respose(code 200)
```
Content-Type: application/octet-stream
```

Example
```shell
curl $remoteUrl -o tmp.car
```

### Confirm propose
Confirm the propose will done the request and release the car file.

Request
```
Uri: /deal/confirm
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form: 
propCid=xxx
remoteUrl=xxxx
```

Response(code 200)
```
ok
```

Example
```shell
curl -d "propCid=xxx&remoteUrl=xxx" "http://127.0.0.1:9080/deal/confirm"
```

## Sign API
call chain api
```
Uri: /chain/api
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form:
method=ClientStatelessDeal
params=urlencode # a serial json urlencode
```
support methods
```
ClientStatelessDeal -- Response {"PropCid":"","Verified":true}
```

## Example
```
run `lotus-datacap chain-srv`
run `lotus-datacap pack-srv`
run `lotus-datacap car-srv`

# make a propose
curl -s -d "minerAddr=t01005&clientAddr=t1j3qjyaauzhvtohwc4ztqrpw5qg2zdlyv7qlvffq&epochDur=518400" "http://127.0.0.1:9080/deal/propose"

# download car file
curl -o /tmp/tmp.car http://10.202.216.33:9080/40321968-bd38-44fa-9a6b-d74aa5794583.car

# import car file
lotus-miner storage-deals import-data bafyreift7dvqu4umhwwkemxj7lqoczwiqc7k6i3iqxzxdjx5jvm3cunkqa /tmp/tmp.car ""

# publish deals
lotus-miner storage-deals pending-publish

# confirm and delete car file
curl -d "propCid=bafyreift7dvqu4umhwwkemxj7lqoczwiqc7k6i3iqxzxdjx5jvm3cunkqa&remoteUrl=http://127.0.0.1:9080/40321968-bd38-44fa-9a6b-d74aa5794583.car" "http://127.0.0.1:9080/deal/confirm"
```
