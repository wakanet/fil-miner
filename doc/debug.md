# 单机验证节点(2k环境)

这里一个内部搭建的2k验证环境，用于模拟单机下的部署, 为模拟真实的环境，需要以下虚拟机配置。

本文档旨在构建一个最简的模拟lotus密封环境，用于学习、测试、验证lotus的使用与维护。

# 目录
- [硬件要求](#硬件要求)
- [软件安装](#软件安装)
- [fil-miner目录说明](#fil-miner目录说明)
- [fil-miner进程关系图](#fil-miner进程关系图)
- [启动链](#启动链)
- [启动miner](#启动miner)
- [启动存储](#启动存储)
- [启动密封工人](#启动密封工人)
- [启动wdpost工人](#启动wdpost工人)
- [启动wnpost工人](#启动wnpost工人)

## 硬件要求
```
* 虚拟机操作系统，ubutun 20或debian都可以, 推荐vbox
* 至少1CPU
* 至少4G内存
* 至少3块盘，系统盘20G 1块，数据盘10G 2块
```

## 软件安装
```
** 不需要root，但需要sudo权限 **

# 安装依赖(不需安装显卡驱动)
sudo aptitude install rsync chrony make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev libcuda1

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


# 下载演示包(演示包中含一个lotus-daemon-1,lotus-user-1,lotus-storage-0,lotus-worker-wnpost,lotus-worker-wdpost,lotus-worker-1进程)
cd ~
wget -c https://github.com/wakanet/fil-miner/release/xxx-debug.tar.gz . 
tar -xzf xxx-debug.tar.gz
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
    - lotus 
      - lotus-user -- lotus运行日常使用的脚本
        - env -- 多节点部署时单台机器上的变量切换脚本
        - lotus.sh -- 等同于lotus命令
        - miner.sh -- 等同于lotus-miner命令
        - shed.sh -- 等同于lotus-shed命令
        - tailf-lotus.sh -- 快速tail -f lotus日志
        - tailf-miner.sh -- 快速tail -f lotus-miner日志
        - 其他脚本是基于上述命令的变程，使用前自行看一下内容
        - export-chain.sh -- 导出链快照
        - test-wdpost.sh -- 手工运行wdpost测试
        - umount-storage.sh -- 手工清理/data/nfs/下的挂载

```

## fil-miner进程关系图
```
lotus-daemon-1 关联目录与文件
/data/cache/.lotus

lotus-user-1 关联目录与文件
/data/cache/.lotus/api, /data/cache/.lotus/token, /data/sdb/lotus-user-1/.lotusminer

lotus-storage-0 关联目录与文件
/data/zfs,fil-miner/var/lotus-storage-0

lotus-worker-1 关联目录与文件
/data/sdb/lotus-user-1/.lotusminer/worker_api, /data/sdb/lotus-user-1/.lotusminer/worker_token, /data/cache/.lotusworker

lotus-worker-wnpost 关联目录与文件
/data/sdb/lotus-user-1/.lotusminer/worker_api, /data/sdb/lotus-user-1/.lotusminer/worker_token, /data/cache/.lotusworker

lotus-worker-wdpost 关联目录与文件
/data/sdb/lotus-user-1/.lotusminer/worker_api, /data/sdb/lotus-user-1/.lotusminer/worker_token, /data/cache/.lotusworker


各进程关系图
                lotus-daemon-1
                      |
                lotus-user-1
      /               |                 \
lotus-storage-0  lotus-worker-1  lotus-worker-wdpost(wnpost)
```

## 启动链 
```
cd ~/fil-miner
. env.sh
filc start lotus-daemon-1
cd script/lotus/lotus-user
. env/lotus-1.sh # 切换lotus.sh的环境变量指向到lotus-daemon-1
./lotus.sh sync status # 查看链状态
# 查看lotus-daemon-1的日志，更多需要时查~/fil-miner/var/log
./tailf-lotus.sh 
```

## 启动miner
```
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
./lotus.sh wallet new bls # 创建一个t3钱包地址
curl http://120.78.167.238:7777/send?address=上面的钱包地址
./lotus.sh wallet list # 确认水龙头的钱到帐号，可以创建miner
./miner.sh init --owner=t3xxx --sector-size=2KiB

# 以上init成功后可以开始运行miner, init只需在首次创建时使用
filc status
filc start lotus-user-1
./tailf-miner.sh # 查看miner日志是否启动成功
filc status # 确认lotus-user-1进程状态是绿的
./miner.sh info # 查看miner信息
```

## 启动存储
```
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
filc status # 确认进程中有lotus-storage-0
filc start lotus-storage-0 # 会自动配置nfs文件，nfs文件将会是只读；写操作需要通过http来操作。
filc status # 确认lotus-storage-0是绿的

# 以下依赖于lotus-user-1已启动
./init-storage-dev.sh # 此脚本内容是挂载lotus-storage-0的存储，更多存储方式参考开发文档或者./miner.sh fstar-storage --help
# 查阅miner中的存储节点状态, 此时显示有两个节点存储被miner管理了
./miner.sh fstar-storage status --debug 

# 因miner会接管理lotus-storage-0的密钥信息，当重建miner时，需要重置lotus-sotrage-0的服务器配置文件
rm -r ~/fil-miner/var/lotus-storage-0
filc restart lotus-storage-0 # 删除配置文件后重启lotus-storage-0服务
```

## 启动密封工人
```
# 以下依赖于lotus-user-1已启动并且./miner.sh fstar-storage status有正常节点
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/lotus-1.sh
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
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
filc status # 确认进程中有lotus-worker-wdpost

filc start lotus-worker-wdpost # 启动进程级wdpost工人
```


## 启动wnpost工人
```
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
filc status # 确认进程中有lotus-worker-wnpost

filc start lotus-worker-wnpost # 启动进程级wnpost工人
```
