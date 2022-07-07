#!/bin/sh

username=$1

if [ -z "$username" ]; then
    echo "need input username"
    exit
fi

adduser $username
