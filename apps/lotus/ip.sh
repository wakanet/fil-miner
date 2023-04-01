#!/bin/sh

getip() {
    defaultIP="127.0.0.1"
    ips=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
    for ip in $ips
    do
        defaultIP=$ip
        break
    done
    echo $defaultIP
}
echo $(getip)
