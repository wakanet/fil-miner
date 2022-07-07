// build lotus-storage-x nodes
package main

import (
	"fmt"
	"io/ioutil"
)

const format = `[program:lotus-storage-%d]
environment=GIN_MODE="release"
directory=$PRJ_ROOT/apps/lotus
command=./lotus-storage.sh $PRJ_ROOT/var/lotus-storage-%d/ /data/zfs :%d :%d :%d
autostart=false
startsecs=3
startretries=3
autorestart=true
exitcodes=0,2
stopsignal=TERM
stopwaitsecs=10
stopasgroup=true
killasgroup=true
stdout_logfile=$PRJ_ROOT/var/log/lotus-storage-%d.logfile.stdout
stdout_logfile_maxbytes=500MB
stdout_logfile_backups=10
stderr_logfile=$PRJ_ROOT/var/log/lotus-storage-%d.logfile.stderr
stderr_logfile_maxbytes=500MB
stderr_logfile_backups=10

`

func main() {
	result := []byte{}
	for i := 100; i < 200; i++ {
		result = append(result, []byte(fmt.Sprintf(`./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="127.0.0.1:%d" --mount-transf-uri="$netip:%d" --mount-dir="/data/nfs" --mount-auth-uri="$netip:%d" --max-size=-1 --sector-size=35433480192 --max-work=100`, 15330+(i*10)+2, 15330+(i*10)+1, 15330+(i*10)))...)
		result = append(result, []byte("\n")...)
	}
	ioutil.WriteFile("tmp.sh", result, 0666)

	//for i := 100; i < 200; i++ {
	//	if err := ioutil.WriteFile(fmt.Sprintf("lotus-storage-%d.ini", i), []byte(fmt.Sprintf(format,
	//		i, i,
	//		15330+(i*10), 15330+(i*10)+1, 15330+(i*10)+2,
	//		i, i,
	//	)), 0666); err != nil {
	//		panic(err)
	//	}
	//}
}
