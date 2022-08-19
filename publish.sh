#!/bin/sh

rel_dir="./publish/fil-miner"

rm -rf $rel_dir 
mkdir -p $rel_dir
cp -r ./apps $rel_dir
cp -r ./bin $rel_dir
cp -r ./etc $rel_dir
cp -r ./doc $rel_dir
cp -r ./script $rel_dir
cp -r install.sh $rel_dir
cp -r README.md $rel_dir
cp -r env.sh $rel_dir
cp -r version $rel_dir

# clean the source
rm -r $rel_dir/etc/supd/apps/*.ini
