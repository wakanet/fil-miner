#!/bin/sh

dir=$1
if [ -z "$dir" ]; then
    echo "need input dir name"
else
    openssl enc -d -aes256 -pbkdf2 -in $dir |tar -xzf -
fi

