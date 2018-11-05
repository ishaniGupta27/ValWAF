#!/bin/bash
nn=$1
#echo $nn
cd ~/ryu
PYTHONPATH=. ./bin/ryu-manager ryu/app/${nn}.py
