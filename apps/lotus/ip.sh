#!/bin/sh

getip() {
    ips=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
    for ip in $ips
    do
        echo $ip
        break
    done
    echo "127.0.0.1"
}
echo $(getip)
