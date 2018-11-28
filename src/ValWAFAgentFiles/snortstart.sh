#!/bin/bash
configFile=$1

sudo -I
sudo snort -i s1-eth1 -c ConfiRepo/Snort_$configFile.conf -A unsock -N -l /tmp
