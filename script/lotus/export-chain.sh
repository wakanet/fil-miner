#!/bin/sh

dl_dir=/data/download

mkdir -p $dl_dir

echo `date`>$dl_dir/export-chain.log

./lotus.sh chain export --recent-stateroots=900 --skip-old-msgs=true $dl_dir/lotus_chain_tmp.car

if [ -f $dl_dir/lotus_chain_snapshot.car ]; then
  mv -v $dl_dir/lotus_chain_snapshot.car $dl_dir/lotus_chain_snapshot.car.bak
fi
if [ -f $dl_dir/lotus_chain_tmp.car ]; then
  mv -v $dl_dir/lotus_chain_tmp.car $dl_dir/lotus_chain_snapshot.car
fi

echo `date`>>$dl_dir/export-chain.log
echo "export lotus_chain_snapshot.car done"


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
# ./lotus.sh daemon --import-snapshot /data/download/lotus_chain_snapshot.car --halt-after-import # 导入快照
# filc start lotus-daemon-1 # 启动链
# filc status # 确认链已启动
# ./lotus.sh sync status #  确认链同步成功
# rm -rf /data/cache/.lotus/datastore.bak
#
