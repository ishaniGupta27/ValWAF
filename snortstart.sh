#!/bin/bash
nn=$1
#echo $nn
sudo -I
sudo snort -i s1-eth1 -c /etc/snort/snort.conf -A unsock -N -l /tmp
