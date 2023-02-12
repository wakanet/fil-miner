## 启动bchain-storage单机存储
此存储通过内置http方式进行读写数据保护，可替换单机的NFS存储
```

cd ~/fil-miner
. env.sh

go install github.com/gwaycc/bchain-storage/cmd/bchain-storage@v1.0.0

cp etc/supd/apps/tpl/lotus-storage-0.ini etc/supd/apps # 准备存储服务器进程
filc reload
filc status

cd script/lotus
. env/miner-1.sh
filc status # 确认进程中有lotus-storage-0
filc start lotus-storage-0 # 会自动配置nfs文件，nfs文件将会是只读；写操作需要通过http来操作。
filc status # 确认lotus-storage-0是绿的

# 以下依赖于lotus-user-1已启动(默认使用bcstorage,NFS请改脚本)
./init-storage-dev.sh # 此脚本内容是挂载lotus-storage-0的存储，更多存储方式参考开发文档或者./miner.sh fstar-storage --help
# 查阅miner中的存储节点状态, 此时显示有两个节点存储被miner管理了
./miner.sh fstar-storage status --debug 

# 因miner会接管理lotus-storage-0的密钥信息，当重建miner时，需要重置lotus-sotrage-0的服务器配置文件
rm -r ~/fil-miner/var/lotus-storage-0
filc restart lotus-storage-0 # 删除配置文件后重启lotus-storage-0服务
```
