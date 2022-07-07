#!/bin/bash

# rename
#https://jingyan.baidu.com/article/b24f6c820c259d86bfe5da1f.html
#usermod -l NewUser -d /home/NewUser -m OldUser
#groupmod -n NewUser OldName

# denyhost
#https://blog.csdn.net/m0_49946916/article/details/108166720
#https://blog.csdn.net/qq_40907977/article/details/102950017

#sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
#sudo cp sources.list /etc/apt/sources.list

#sudo apt-get update
#sudo apt-get install chrony python unattended-upgrades
#sudo unattended-upgrades # maybe need reboot the system


# for denyhosts
python -V
ldd /usr/sbin/sshd |grep wrap
#wget https://github.com/denyhosts/denyhosts/archive/v2.10.tar.gz
tar -xzf denyhosts-2.10.tar.gz
cd denyhosts-2.10
sudo python setup.py install
sudo cp denyhosts.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable denyhosts
sudo systemctl restart denyhosts
cd -

# for time server
#sudo cp ./chrony.conf /etc/chrony/chrony.conf
#sudo restart chrony

# no root remote login
sudo cp ./sshd_config.miner /etc/ssh/sshd_config 
sudo systemctl restart sshd

# optimize log
sudo cp logrotate.conf /etc/logrotate.conf
sudo systemctl restart syslog

# open the iptables
./iptables-miner.sh

# view os account
cat /etc/passwd|grep -v nologin|grep -v halt|grep -v shutdown|awk -F":" '{ print $1"|"$3"|"$4 }'|more
# /etc/sudoers
#lotus ALL=(ALL) NOPASSWD: ALL
