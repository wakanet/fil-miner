#!/bin/sh

# 参考资料
# https://www.cnblogs.com/suihui/p/4334224.html
# http://cnzhx.net/blog/common-iptables-cli/

# 注意将开机设为启动项，并且禁用其他防火墙，以免功能冲突
sudo apt-get -y install iptables-persistent

# 先放行所有数据，等待端口配置后再启用拒绝
sudo iptables -P INPUT ACCEPT
sudo iptables -F
sudo iptables -P INPUT ACCEPT

# 允许出行连接的所有数据通行
sudo iptables -I INPUT -m state --state INVALID -j DROP
sudo iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# 允许icmp包
sudo iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# 允许本机
sudo iptables -A INPUT -i lo -j ACCEPT -m comment --comment "for local host" 

# 白名单机器
#sudo iptables -I OUTPUT -d 10.1.30.249 -p all -j ACCEPT -m comment --comment "slave server"

#　对外开放以下端口
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "for ssh"

# 复制上面的这一条127下来变更为miner机的ip
# 禁止其他机器连接，只允许需要的进行连接链
#sudo iptables -I INPUT -s xx.xx.xx.xx -ptcp --dport 11234 -j ACCEPT -m comment --comment "for lotus api"

sudo iptables -A INPUT -p tcp --dport 12340 -j ACCEPT -m comment --comment "for lotus libp2p"
sudo iptables -A INPUT -p tcp --dport 14470 -j ACCEPT -m comment --comment "for lotus libp2p"
sudo iptables -A INPUT -p tcp --dport 14471 -j ACCEPT -m comment --comment "for lotus libp2p"
sudo iptables -A INPUT -p tcp --dport 14472 -j ACCEPT -m comment --comment "for lotus libp2p"

# for miner
sudo iptables -A INPUT -p tcp --dport 2348 -j ACCEPT -m comment --comment "for lotus-miner worker api"
# TODO: for storage
#sudo iptables -A INPUT -p tcp --dport 111 -j ACCEPT -m comment --comment "for rpcbind"

#过滤所有非以上规则的请求
sudo iptables -P INPUT DROP

# 保存数据
sudo netfilter-persistent save
# sudo service iptables save # on centos
# 重启防火墙
# sudo service iptables restart # on centos

# show rules
sudo iptables -L -n --line-num
