#!/bin/bash
valWaf=$1
pemFile=$2
ruleFile=$3
valAgent=$4
pemFileAgent=$5
current_time=$(date "+%Y/%m/%d-%H/%M")
ppcapFile=${ruleFile//.rules/}
echo "trafficFile:" "$ppcapFile"

#send rule file to ValWAF
scp -i ${pemFile} ${ruleFile} ubuntu@${valWaf}:/home/ubuntu/WebApplicationFirewall/src/ValWAFFiles/RulesRepo

#send rule file to ValWAF
scp -i ${pemFile} ${pemFileAgent} ubuntu@${valWaf}:/home/ubuntu/WebApplicationFirewall/src/ValWAFFiles/ppcap

#tmux for starting server
tmux -2 new-session -d -s startServer
tmux send -t startServer " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t startServer "  sudo python -m SimpleHTTPServer 80 &" ENTER
tmux detach -s startServer

#tmux for trackng traffic
tmux -2 new-session -d -s trackTraffic
tmux send -t trackTraffic " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t trackTraffic " cd WebApplicationFirewall/src/ValWAFFiles/ppcap" ENTER
tmux send -t trackTraffic " ./startTracking.sh $ppcapFile" ENTER
tmux detach -s trackTraffic

#start sending malicious traffic
tmux -2 new-session -d -s maliciousTrafficGenerator
tmux send -t maliciousTrafficGenerator " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t maliciousTrafficGenerator " cd WebApplicationFirewall/src/ValWAFFiles/ppcap" ENTER
tmux send -t maliciousTrafficGenerator " ./make_ppcap.sh $ruleFile" ENTER
#stop tracking traffic
tmux send -t maliciousTrafficGenerator " ./stopTracking.sh" ENTER
#send file to ValWAFAgent
tmux detach -s maliciousTrafficGenerator

sleep 10

tmux kill-session -t startServer
tmux kill-session -t trackTraffic
tmux kill-session -t maliciousTrafficGenerator




#attach to session
tmux -2 new-session -d -s sendPcapFile
tmux send -t sendPcapFile " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t sendPcapFile " cd WebApplicationFirewall/src/ValWAFFiles/ppcap" ENTER
tmux send -t sendPcapFile " ./sendPcap.sh $ppcapFile $valAgent" ENTER
tmux detach -s sendPcapFile

