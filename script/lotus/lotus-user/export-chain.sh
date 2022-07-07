#!/bin/sh

./lotus.sh chain export --recent-stateroots=900 --skip-old-msgs=true lotus_chain_$(date +%Y%m%d).car
echo "export lotus_chain_$(date +%Y%m%d).car done"

# 从快照恢复指南
# Start lotus with the export chain
# 加载环境变量
# cd ~/fil-miner
# .env.sh
# 
# 加载环境变量
# cd ~/fil-miner/script/lotus/lotus-user
# . env/lotus-1.sh
#
# 导出链
# nohup ./export-chain.sh &
# tail nohup.out # 确认导出完成
# 
# Login the server who need the chain
# 登录需要重建的链
# filc stop lotus-daemon-1 # 停止原服务
# filc status # 确认链已停止
# mv /data/cache/.lotus/datastore /data/cache/.lotus/datastore.bak # 备份原链数据
# ./lotus.sh daemon --import-snapshot ./lotus_chain_20220705.car --halt-after-import # 导入快照
# filc start lotus-daemon-1 # 启动链
# filc status # 确认链已启动
# ./lotus.sh sync status #  确认链同步成功
# rm -rf /data/cache/.lotus/datastore.bak
#
