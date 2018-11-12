#!/bin/bash
nn=$1
#echo $nn
sudo -I
sudo suricata -c /etc/suricata/suricata.yaml -i s1-eth1 --init-errors-fatal
