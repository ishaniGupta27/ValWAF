#!/bin/bash
valWaf=$1
pemFile=$2
ruleFile=$3
valAgent=$4
pemFileAgent=$5
ruleFileAgent=$6
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

sleep 5

tmux kill-session -t startServer
tmux kill-session -t trackTraffic
tmux kill-session -t maliciousTrafficGenerator




#attach to session
tmux -2 new-session -d -s sendPcapFile
tmux send -t sendPcapFile " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t sendPcapFile " cd WebApplicationFirewall/src/ValWAFFiles/ppcap" ENTER
tmux send -t sendPcapFile " ./sendPcap.sh $ppcapFile $valAgent" ENTER
tmux detach -s sendPcapFile

sleep 5
tmux kill-session -t sendPcapFile

#send rule file to ValWAFAgent
scp -i ${pemFileAgent} ${ruleFileAgent} ubuntu@${valAgent}:/home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/RulesRepo/

#tmux for starting server
tmux -2 new-session -d -s reconfigSnort_RunTraf
tmux send -t reconfigSnort_RunTraf " ssh -i ${pemFileAgent} ubuntu@${ruleFileAgent} " ENTER
tmux send -t reconfigSnort_RunTraf "  cd WebApplicationFirewall/src/ValWAFAgentFiles" ENTER #
tmux send -t reconfigSnort_RunTraf " ./configSnortTemp.sh ${ruleFileAgent//.rules/}" ENTER #make new config filr from template #tog with prev
tmux send -t reconfigSnort_RunTraf " " ENTER #run ppcapFile 
tmux send -t reconfigSnort_RunTraf " " ENTER #stop Snort
tmux send -t reconfigSnort_RunTraf " " ENTER #mv orign config file
#tmux send -t reconfigSnort_RunTraf " " ENTER #start snort
tmux detach -s reconfigSnort_RunTraf

#logs to engine in ValWAF



