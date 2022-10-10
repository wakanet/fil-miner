# 通过官方Lotus构建密封

若版本已过时，请以官方指令为准，本版本适用于示例以及小规模部署。

建议在单机上完成部署熟释后再拆分到各机器部署。

## 下载fil-miner
```
cd ~
git clone https://github.com/wakanet/fil-miner.git
cd fil-miner
. env.sh
go install github.com/gwaycc/supd/cmd/supd@latest
go install github.com/gwaycc/etcd/cmd/etcd@v0.0.3
go install github.com/gwaycc/etcd/cmd/etcdctl@v0.0.3
./install.sh install # 安装
# 移除执行./install.sh clean
```

## Fork源版本构建lotus二进制
https://github.com/free1139/lotus.git
```
cd ~
git clone https://github.com/free1139/lotus.git
cd lotus
git checkout devnet
make clean
./install.sh # 默认为mainet网络，
# ./install.sh calibnet # calibration网络
```

## 打二进制fil-miner包
```
./publish.sh
cd publish
tar -czf fil-miner-mainnet-v1.x.x.tar.gz fil-miner
```

# 部署

得到fil-miner-mainnet-v1.x.x.tar.gz,并解压会得到fil-miner目录
```
cd ~
tar -xzf fil-miner-mainnet-v1.x.x.tar.gz
```

以1台链(含miner机), 1台P1P2 worker机, 1台C2 worker机例, 1台WDPoSt机器，1台NFS机为示例

## 部署链与Miner机器
```
cd ~/fil-miner
. env.sh
cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps
cp etc/supd/apps/tpl/lotus-user-1.ini etc/supd/apps
filc reload
filc status # 会列出fild管理的进程

# 启动链
# 数据(repo=/data/cache/.lotus), 
# 日志(~/fil-miner/var/log/lotus-daemon-1.logfile.stderr）
cd script/lotus/lotus-user
filc start lotus-daemon-1
filc status # 显示lotus-daemon-1已启动
. env/miner-1.sh # 导入脚本需要的环境变量
./lotus.sh status # 显示链状态, 等价于lotus命令，具体`cat ./lotus.sh`

# 导入或创建SP钱包
./lotus.sh wallet new bls # 以创建为例
./lotus.sh wallet list # 查询钱包，如果里边没钱，需要从别处获得FIL

# 初始化miner, 已有跳过
# 数据(miner-repo=/data/sdb/lotus-user-1/.lotusminer), 
# 日志(~/fil-miner/var/log/lotus-user-1.logfile.stderr）
./miner.sh init --owner=钱包地址 --sector-size=32GiB # 或已创建过，跳过此步

# 准备存储, 已有跳过
sudo mkdir -p /data/nfs/1
sudo mount -t nfs 存储机地址:可读写路径 /data/nfs/1
sudo cp /data/sdb/lotus-user-1/.lotusminer/sectorstore.json /data/nfs/1
sudo vim /data/nfs/1/sectorstore.json
# 修改ID为唯一值
# 修改CanSeal为false
# 修改CanStore为true
# :wq 保存并退出修改

# 配置.lotusminer的存储路径
sudo vim /data/sdb/lotus-user-1/.lotusminer/sectorstore.json
# 修改ID为唯一值
# 修改CanSeal为false
# 修改CanStore为false
# :wq 保存并退出修改
sudo vim /data/sdb/lotus-user-1/.lotusminer/storage.json
#{
#  "StoragePaths": [
#    {
#      "Path": "/data/sdb/lotus-user-1/.lotusminer"
#    },
#    {
#      "Path": "/data/nfs/1"
#    }
#  ]
#}
# :wq 保存并退出修改

#启动miner
# 数据(miner-repo=/data/sdb/lotus-user-1/.lotusminer), 
# 日志(~/fil-miner/var/log/lotus-user-1.logfile.stderr）
filc start lotus-user-1
filc status
filc tail -f lotus-user-1 stderr # 可跟踪日志，ctrl+c退出
```

## 部署P1P2机器
```
# 安装fil-miner
cd ~/fil-miner
. env.sh
cp etc/supd/apps/tpl/lotus-plworker-t12.ini etc/supd/apps
./install.sh install
filc status

# 挂载存储
sudo mkdir -p /data/cache/.lotusworker
sudo mount -t nfs 存储机地址:可读写路径 /data/nfs/1
sudo vim /data/cache/.lotusworker/storage.json
#{
#  "StoragePaths": [
#    {
#      "Path": "/data/cache/.lotusworker"
#    },
#    {
#      "Path": "/data/nfs/1"
#    }
#  ]
#}
# :wq 保存并退出修改

# 加载miner api信息
sudo mkdir -p /data/sdb/lotus-user-1/.lotusminer
# 将lotus-user-1机器上的.lotusminer/api与.lotusminer/token复制过来
# !!!!注意!!!!此方式会将miner的api全部授权给worker机器，要注意信息安全

# 启动worker
filc start lotus-worker-t12
```

## 部署C2机器
```
# 安装fil-miner
cd ~/fil-miner
. env.sh
cp etc/supd/apps/tpl/lotus-plworker-c2.ini etc/supd/apps
./install.sh install
filc status

# 加载miner api信息
sudo mkdir -p /data/sdb/lotus-user-1/.lotusminer
# 将lotus-user-1机器上的.lotusminer/api与.lotusminer/token复制过来
# !!!!注意!!!!此方式会将miner的api全部授权给worker机器，要注意信息安全

# 启动worker
filc start lotus-worker-c2
```

## 部署专用WdPoSt机器
```
# 安装fil-miner
cd ~/fil-miner
. env.sh
cp etc/supd/apps/tpl/lotus-plworker-wdpost.ini etc/supd/apps
./install.sh install
filc status

# 挂载存储
sudo mkdir -p /data/cache/.lotusworker-wd
sudo mount -t nfs 存储机地址:可读写路径 /data/nfs/1
sudo vim /data/cache/.lotusworker-wd/storage.json
#{
#  "StoragePaths": [
#    {
#      "Path": "/data/nfs/1"
#    }
#  ]
#}
# :wq 保存并退出修改

# 加载miner api信息
sudo mkdir -p /data/sdb/lotus-user-1/.lotusminer
# 将lotus-user-1机器上的.lotusminer/api与.lotusminer/token复制过来
# !!!!注意!!!!此方式会将miner的api全部授权给worker机器，要注意信息安全

# 启动worker
filc start lotus-worker-wdpost
```

## 部署专用WnPoSt机器
```
# 安装fil-miner
cd ~/fil-miner
. env.sh
cp etc/supd/apps/tpl/lotus-plworker-wnpost.ini etc/supd/apps
./install.sh install
filc status

# 挂载存储
sudo mkdir -p /data/cache/.lotusworker-wn
sudo mount -t nfs 存储机地址:可读写路径 /data/nfs/1
sudo vim /data/cache/.lotusworker-wn/storage.json
#{
#  "StoragePaths": [
#    {
#      "Path": "/data/nfs/1"
#    }
#  ]
#}
# :wq 保存并退出修改

# 加载miner api信息
sudo mkdir -p /data/sdb/lotus-user-1/.lotusminer
# 将lotus-user-1机器上的.lotusminer/api与.lotusminer/token复制过来
# !!!!注意!!!!此方式会将miner的api全部授权给worker机器，要注意信息安全

# 启动worker
filc start lotus-worker-wdpost
```

## 开始CC密封
```
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/miner-1.sh
./miner.sh sectors pledge # 一次只能发起一个Addpiece
```

# 官方版本切换至fstar版本

只需解决注意存储挂载的与钱包加密问题

TODO:详细操作
