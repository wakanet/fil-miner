#!/bin/bash

. `pwd`/env.sh # 加载环境变量

echo ""

bootName=""
# 自动判断操作系统
case `uname` in
    "Linux"|"linux")
	files="/etc/redhat-release /etc/issue"
	for file in $files
	do
	    if [ ! -f "$file" ]; then
		continue
	    fi
            sysname=$(cat $file |awk -F " " '{print $1}')
            case $sysname in
                "Debian")
                    bootName="boot_debian.sh "
		    break
                    ;;
                "Ubuntu")
                    bootName="boot_debian.sh "
		    break
                    ;;
                "CentOS")
                    bootName="boot_centos.sh "
		    break
                    ;;
                    # TODO:自动识别更多的版本
            esac
         done
    ;;
    "Darwin")
        osName="Darwin"
    ;;
esac

if [ -z "${bootName}" ]; then
    echo "此版本暂未支持安装, 请联系客服"
    exit 0
fi

case "$1" in 
    "install")
        cd script
        ./${bootName} install
        echo "install done"
        cd ..
        ;;
    "clean")
        cd script
        ./${bootName} clean
        cd ..
        ;;
    *)
        echo "install -- to install on system boot"
        echo "clean -- to remove system bootable"
        ;;
esac


