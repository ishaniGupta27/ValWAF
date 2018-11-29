#!/bin/bash
configFile=$1

sudo -I
sudo snort -i s1-eth1 -c ConfiRepo/Snort_$configFile.conf -A Full -l /home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/logs 2>&1 | tee stdlogs.txt