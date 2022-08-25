#节点状态告警

## lotus节点上，监控以下值，达到指定阀值是为异常 
```
# 输出值>3，链与当前调度差超过了3个高度, 说明同步不及时. 建议每个wdpost周期检查2次, 主网为15分钟1次
# 处理：检查链相关环境是否正常
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus chain-diff 

# 输出值<1099511627776, /data/cache.lotus/datastore所在的磁盘剩余值小于1TB. 建议1天检查两次
# 处理：需要及时裁剪链，否则磁盘空间可能会满
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus chain-disk

# 输出值>2时，本地消息池序列异常丢失，需要人工修复, 建议1小时检查一次.
# 处理：人工进行消息序列修复(lotus-shed noncefix --help)
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus chain-mpool --future


# 以下为密封时按需监控

# 可选，大于指定值时告警, 输出值当前本地消息池的消息量，按实现密封情况告警
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus chain-mpool --current

# 可选，大于指定值时告警，输出当前的消息gas费用的basefee值，当basefee值过高时，应告警是否暂停密封 
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus chain-basefee
```

## 在miner节点上, 监控以下值，达到指定阀值是为异常
```
# 输出值>10时，最后两轮wdpost的掉的扇区数大于10值, 建议每个wdpost周期检查2次, 主网为15分钟1次
# 处理：检查wdpost是否正常工作
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus --miner-repo=/data/sdb/lotus-user-1/.lotusminer miner-wdpost-faults

# 输入值>0时，当天UTC零时起的出块异常数量，建议每小时检查一次
# 处理：检查wnpost是否正常工作
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus --miner-repo=/data/sdb/lotus-user-1/.lotusminer miner-wnpost-err

# 输入值>0时存在异常的存储节点
# 处理：检查miner机器上的挂载的存储是否正常
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus --miner-repo=/data/sdb/lotus-user-1/.lotusminer miner-storage

# 可选，小于指定值时告警，监控当前出块率，但正在密封时出块率会小于100%　建议以平均出一个块的时间为统计周期
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus --miner-repo=/data/sdb/lotus-user-1/.lotusminer miner-wnpost-rate

# 可选，监控当前24小时密封扇区输出，单位为个，需要根据实际产线worker数据来设定值，若小于指定产能, 则worker机器有异常
# 处理：排查worker机器是否全部在正常工作(lotus-miner fstar-worker stat-seal-time)
/root/fil-miner/apps/lotus/lotus-health --repo=/data/cache/.lotus --miner-repo=/data/sdb/lotus-user-1/.lotusminer miner-seal
```
