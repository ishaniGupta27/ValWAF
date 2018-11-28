#!/bin/bash

#stop snort
cd /etc/init.d
./snort stop
#move orig config file back
rm -f /etc/snort/snort.conf 
mv  /etc/snort/snort.conf_orig /etc/snort/snort.conf 

#START SNORT Maybe or maybenot
