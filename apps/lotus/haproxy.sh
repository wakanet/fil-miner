#!/bin/sh

# need install haproxy, example in ubuntu
# sudo aptitude install haproxy

haproxy -db -f ../../etc/haproxy.cfg
