#!/bin/bash

PRJ_ROOT=$(dirname `pwd`)
srvHome=/usr/lib/systemd/system
srvName="fild"

case "$1" in 
    "install")
        if [ -f $srvHome/$srvName.service  ]; then
            echo "Already installed"
            exit 0
        fi
        echo "PRJ_ROOT:"$PRJ_ROOT
        cat $srvName.service|awk '{gsub("\\$PRJ_ROOT","'$PRJ_ROOT'");print $0}'>tmp.service
        sudo cp tmp.service $srvHome/$srvName.service 
        rm tmp.service
        sudo systemctl daemon-reload
        sudo systemctl enable $srvName
        sudo systemctl start $srvName
        ;;
    "clean")
        if [ -f $srvHome/$srvName.service ]; then
            sudo systemctl stop $srvName
            sudo systemctl disable $srvName
            sudo rm $srvHome/$srvName.service 
            sudo systemctl daemon-reload
        else
            echo "Not installed"
        fi
        ;;
    *)
        echo "install -- to install on system boot"
        echo "clean -- to remove system bootable"
        ;;
esac
