#!/bin/bash
valWaf=$1
valAgent=$2
pemFileAgent=$3
ppcapFile=$4

#send rule file to ValWAF
scp -i ${pemFileAgent} ${pemFileAgent} ubuntu@${valWaf}:/home/ubuntu/WebApplicationFirewall/src/ValWAFFiles/ppcap

#attach to session
tmux attach -t maliciousTrafficGenerator
tmux send -t maliciousTrafficGenerator " ./sendPcap.sh $ppcapFile $valAgent" ENTER
