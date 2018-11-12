#!/bin/bash
nn=isha_snort
#echo $nn
cd ~/ryu
PYTHONPATH=. ./bin/ryu-manager ryu/app/${nn}.py
