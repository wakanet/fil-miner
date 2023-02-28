# 单机验证节点

单机节点主要用于演示与示例，掌握后结合mainnet.md进行生产部署。

本文档旨在构建一个最简的模拟lotus密封环境，用于学习、测试、验证lotus的使用与维护。

# 目录
- [硬件要求](#硬件要求)
- [依赖安装](#依赖安装)
- [软件部署](#软件部署)
- [fil-miner目录说明](#fil-miner目录说明)
- [fil-miner进程关系图](#fil-miner进程关系图)
- [启动链](#启动链)
- [启动miner](#启动miner)
- [启动存储](#启动存储)
- [启动密封工人](#启动密封工人)
- [启动wdpost工人](#启动wdpost工人)
- [启动wnpost工人](#启动wnpost工人)
- [启动CC密封](#启动CC密封)
- [启动DC密封](#启动DC密封)

## 硬件要求
2k环境
```
* 虚拟机操作系统，ubutun 20或debian都可以, 推荐vbox
* 至少2CPU
* 至少4G内存
* 建议3块虚拟盘，系统盘20G 1块，数据盘1G(或自定义) 2块
```
cablinet环境
```
# 参考mainnet.md的硬件要求
sudo aptitude install rsync make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev
sudo aptitude install chrony # 按需安装
sudo aptitude install nvidia-driver-510-server
```

## 依赖安装
2k环境
```
** 不需要root，但需要sudo权限 **

# 安装依赖(不需安装显卡驱动)
sudo aptitude install rsync make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev
sudo aptitude install chrony # 时间同步服务，按需
sudo aptitude install nfs-server nfs-client # 启用NFS作为存储
```

32GB及以下环境
```
参考mainnet.md的软件环境
```

## 软件部署
```
# 创建数据目录
sudo mkdir -p /data

# 安装zfs单机盘的存储
sudo aptitude install zfsutils nfs-server
# 注意以lsblk显示的盘位为准,这里以两副本作为演示, 正式部署至少为raidz2
sudo zpool create data-zfs -m /data/zfs mirrors /dev/sdb /dev/sdc

# /data/cache一般挂载高速ssd, 这里用软链作为演示, 也可直接用挂载到/data上的盘
ln -s /data/zfs /data/cache 
# /data/sdb 一般挂载低速hhd盘，若有多个盘，可依次挂载为sdc,sdd等, 这里用软链作为演示,也可直接用挂载到/data上的盘
ln -s /data/zfs /data/sdb 

# 将参数包放这里,　参数包需要放在高速盘中
mkdir -p /data/cache/filecoin-proof-parameters/v28 


# 下载fil-miner管理器
cd ~
git clone https://github.com/wakanet/fil-miner.git
cd fil-miner
./install.sh install # 卸载./isntall.sh clean

. env.sh # 加载运行fil-miner的环境变量
# fild, filc是supervisor的改版，supervisor是一个类似于systemd的进程管理器，
# 为了统一平台适配性与独立性，增加了supervisor单独的进程管理
filc status  # 显示出filc下管理的进程
```

## fil-miner目录说明
```
fil-miner -- 软件根目录
  - bin -- fil-miner管理软件
  - apps -- fil-miner管理的app
    - lotus -- lotus的启动程序
  - var -- fil-miner运行中产生的动态数据, 例如：进程信息，日志输出等，等同于/var设计
    - log -- 日志存放，单个文件大小由各进程配置文件配置
    - lotus-storage-0 -- zfs管理进程的动态数据存储
  - doc -- 文档目录
  - etc -- fil-miner配置文件,等同于/etc设计
    - supd -- fil-miner运行的配置文件
      - supd.ini -- fil-miner进程的启动文件
      - apps -- fil-miner运行的进程配置文件
        - tpl -- 进程配置文件模板
  - script -- 辅助运行脚本
    - denyhosts -- 防火墙配置脚本
    - boot_*.sh -- fil-miner系统安装脚本
    - fild.service -- fil-miner系统自启动配置文件
    - lotus -- lotus运行日常使用的脚本
      - env -- 多节点部署时单台机器上的变量切换脚本
      - lotus.sh -- 等同于lotus命令
      - miner.sh -- 等同于lotus-miner命令
      - shed.sh -- 等同于lotus-shed命令,常用工具集
      - health.sh -- 等同于lotus-health命令，健康状态检查指令，可用于集成到监控系统
      - tailf-lotus.sh -- 快速tail -f lotus日志
      - tailf-miner.sh -- 快速tail -f lotus-miner日志
      - 其他脚本是基于上述命令的变程，使用前自行看一下内容
      - export-chain.sh -- 导出链快照
      - test-wdpost.sh -- 手工运行wdpost测试
      - umount-storage.sh -- 手工清理/data/nfs/下的挂载
```

## fil-miner进程关系图
```

各进程关系图
                lotus-daemon-1
                      |
                lotus-user-1
      /               |                 \
lotus-storage-0 lotus-worker-1(sealing) lotus-worker-wdpost(wnpost)


进程说明
-------------------
lotus-daemon-1 关联目录与文件
/data/cache/.lotus

lotus-user-1 关联目录与文件
/data/sdb-1/.lotusminer
/data/sdb-1/.lotus-proxy/api, /data/sdb-1/.lotus-proxy/token # 若存在，优先使用
/data/cache/.lotus/api, /data/cache/.lotus/token # 若.lotus-proxy不存在，则启动此目录

lotus-storage-0 关联目录与文件
/data/zfs,fil-miner/var/lotus-storage-0

lotus-worker-1 关联目录与文件
/data/sdb-1/.lotusminer/worker_api, /data/sdb-1/.lotusminer/worker_token, /data/cache/.lotusworker

lotus-worker-wnpost 关联目录与文件
/data/sdb-1/.lotusminer/worker_api, /data/sdb-1/.lotusminer/worker_token, /data/cache/.lotusworker

lotus-worker-wdpost 关联目录与文件
/data/sdb-1/.lotusminer/worker_api, /data/sdb-1/.lotusminer/worker_token, /data/cache/.lotusworker
```

## 创建创世节点(开源版）
```
cd ~
git clone https://github.com/free1139/lotus.git
cd lotus
git checkout devnet
make clean
./install.sh debug # 首次编译

#./clean-bootstrap.sh # 清理原创世节点
./init-bootstrap.sh
# 等完成初始化后执行以下
./deploy-bootstrap.sh

# 生成lotus二进制命令
./install.sh debug
```

## 启动链 
```
cd ~/fil-miner
. env.sh

cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps # 准备lotus链进程
filc reload
filc status

cd script/lotus
./lotus.sh fetch-params 2KiB # 首次使用时需手工检查参数包, 其他为512MiB, 32GiB, 64GiB

filc start lotus-daemon-1
. env/miner-1.sh # 切换lotus.sh的环境变量指向到lotus-daemon-1
./lotus.sh sync status # 查看链状态
# 查看lotus-daemon-1的日志，更多需要时查~/fil-miner/var/log
./tailf-lotus.sh 
```

## 启动miner
```
cd ~/fil-miner
. env.sh

cp etc/supd/apps/tpl-1.ini etc/supd/apps # 准备miner进程
filc reload 
filc status

cd script/lotus
. env/miner-1.sh
./lotus.sh wallet new bls # 创建一个t3钱包地址
# sudo lotus send t3地址1000从水龙头这获得
./lotus.sh wallet list # 确认水龙头的钱到帐号，可以创建miner

./lotus.sh fetch-params 2KiB # 首次使用时需手工检查参数包, 其他为512MiB, 32GiB, 64GiB

./miner.sh init --owner=t3xxx(上面创建的钱包地址) --sector-size=2KiB

# 以上init成功后可以开始运行miner, init只需在首次创建时使用
filc status
filc start lotus-user-1
./tailf-miner.sh # 查看miner日志是否启动成功
filc status # 确认lotus-user-1进程状态是绿的
./miner.sh info # 查看miner信息
```

## 启动存储
```
# 配置nfs服务器
mkdir -p /data/zfs/lotus-user-1/staging/deal-staging
mkdir -p /data/zfs/lotus-user-1/unseal/unsealed
mkdir -p /data/zfs/lotus-user-1/sealed/sealed
echo "/data/zfs *(rw,sync,insecure,no_root_squash)">>/etc/exports # 可选，若已有，不需再执行
sudo systemctl reload nfs-server

# 初始化miner中的配置
cd ~/fil-miner
. env.sh
cd script/lotus
. env/miner-1.sh
filc status
./init-storage-dev.sh nfs # 详见脚本内容，会启用staging、unseal、sealed三个存储
./miner.sh fstar-storage status --debug 
```

## 启动密封工人
```
# 以下依赖于lotus-user-1已启动并且./miner.sh fstar-storage status有正常节点
cd ~/fil-miner
. env.sh

cp etc/supd/apps/tpl/lotus-worker-1.ini etc/supd/apps # 准备miner进程
filc reload
filc status

cd script/lotus
. env/miner-1.sh
filc status # 确认进程中有lotus-worker-1

filc start lotus-worker-1 # 启动一个完整流程的密封工人

./miner.sh fstar-worker list # 此时应该看到有一个worker
./miner.sh pledge-sector start # 启动空扇区密封任务生成器，至少会自动生成一个
./miner.sh pledge-sector stop # 停止密封任务生成器

filc tail lotus-worker-1 stderr -f # 查看lotus-worker-1的密封过程,或tail -f var/log下的日志
# ctrl+c退出
```

## 启动wdpost工人
```
cd ~/fil-miner
. env.sh

cp etc/supd/apps/tpl/lotus-worker-wdpost.ini etc/supd/apps # 准备wdpost进程
filc reload
filc status

cd script/lotus
. env/miner-1.sh
filc status # 确认进程中有lotus-worker-wdpost

filc start lotus-worker-wdpost # 启动进程级wdpost工人
```


## 启动wnpost工人
```
cd ~/fil-miner
. env.sh

cp etc/supd/apps/tpl/lotus-worker-wnpost.ini etc/supd/apps # 准备wnpost进程
filc reload
filc status

cd script/lotus
. env/miner-1.sh
filc status # 确认进程中有lotus-worker-wnpost

filc start lotus-worker-wnpost # 启动进程级wnpost工人
```

## 启动CC密封
```
cd ~/fil-miner
. env.sh

cd script/lotus
. env/miner-1.sh
./miner.sh pledge-sector start # 自动发送CC pledge指令
# ./miner.sh pledge-sector stop # 停止发送CC pledge指令
```

## 启动DC密封
### 签名有效数据
```
cd ~/fil-miner
. env.sh
cd script/lotus
./lotus.sh wallet import t14po2vrupy7buror4g55c7shlcrmwsjxbpss7dzy-dev.dat
./lotus.sh wallet new # 创建公证人地址
sudo lotus send [公证人地址] 10
./shed.sh verifreg add-verifier t14po2vrupy7buror4g55c7shlcrmwsjxbpss7dzy [公证人地址] 1024000 # 添加公证人或者./verifreg.sh [公证人地址]
./lotus.sh wallet new # 创建一个有效数据客户端地址
sudo lotus send [客户端地址] 10000 # 从水龙头处获得点钱
./lotus.sh filplus grant-datacap --from [公证人地址] [客户端地址] 10240 # 或者./filplus-grant [公证人地址] [客户端地址]
```

### 选择DC的缓存存储
方案一，默认miner模式
```
# 不需要做什么
```
方案二，启用NFS存储模式，此模式注意数据流网卡走向
```
sudo mv /data/sdb/lotus-user-1/.lotusminer/deal-staging /data/sdb/lotus-user-1/.lotusminer/deal-staging.bak
sudo ln -s /data/nfs/lotus-user-1/1/staging/deal-staging /data/sdb/lotus-user-1/.lotusminer/deal-staging
```

### 发送DC密封
```
# 设置离线传输询价
./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --max-piece-size 2KiB

# 专用离线版本
echo "$HOME/fil-miner/script/lotus/lotus.sh" >> /tmp/files.txt

# 使用方案一miner存储
./miner.sh storage-deals offline-make --from [有效数据地址] /tmp/files.txt 

# 使用方案二nfs存储, 需要填写指定的fstar-storage的kind=2的存储
./miner.sh storage-deals offline-make --storage-id=[1] --from [有效数据地址] /tmp/files.txt 
```

***备注:***
开源版本请使用官方命令文档

