#!/bin/sh

dir=$1
if [ -z "$dir" ]; then
    echo "need input dir name"
else
    tar -czf - ./$dir |openssl enc -e -aes256 -pbkdf2 -out=$dir.dat && rm -r $dir
fi

