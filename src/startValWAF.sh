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
tmux send -t maliciousTrafficGenerator " cd WebApplicationFirewall/src/ValWAFFiles" ENTER
tmux send -t maliciousTrafficGenerator " g++ -std=c++11 MaliciousTrafficGenerator/idsEventGenerator.cpp -lcurl " ENTER
tmux send -t maliciousTrafficGenerator " cd ppcap" ENTER
tmux send -t maliciousTrafficGenerator " ./make_ppcap.sh $ruleFile" ENTER

sleep 10
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

#
#tmux for starting server
tmux -2 new-session -d -s reconfigSnort
tmux send -t reconfigSnort " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t reconfigSnort "  cd WebApplicationFirewall/src/ValWAFAgentFiles" ENTER #
tmux send -t reconfigSnort " ./configSnortTemp.sh ${ruleFileAgent//.rules/}" ENTER # New config : src/ValWAFAgentFiles/ConfiRepo 
tmux detach -s reconfigSnort

echo 'Working perfect till here i.e. having new config file in ConfiRepo  '


tmux -2 new-session -d -s startSimulator
#tmux send -t startSimulator "  cd WebApplicationFirewall/src/Simulator" ENTER 
tmux new-window -n mininet -t startSimulator
tmux send -t startSimulator " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t startSimulator:1 " cd WebApplicationFirewall/src/Simulator" ENTER
tmux send -t startSimulator:1 " sudo mn -c" ENTER
tmux send -t startSimulator:1 " ./startMininet.sh" ENTER
tmux new-window -n ryu -t startSimulator 
tmux send -t startSimulator " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t startSimulator:2 " cd WebApplicationFirewall/src/Simulator" ENTER
tmux send -t startSimulator:2 " ./ryu.sh" ENTER
tmux detach -s startSimulator
echo 'Simulator set up completed'

sleep 3
#tmux kill-session -t reconfigSnort

tmux -2 new-session -d -s runSnort
tmux send -t runSnort " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t runSnort "  cd WebApplicationFirewall/src/ValWAFAgentFiles" ENTER #
tmux send -t runSnort "./snortstart.sh ${ruleFileAgent//.rules/}" ENTER # Snort started with new config !
tmux detach -s runSnort

tmux -2 new-session -d -s runTraffic
tmux send -t runTraffic " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t runTraffic "  cd WebApplicationFirewall/src/ValWAFAgentFiles/trafficRepo" ENTER #
tmux send -t runTraffic "sudo tcpreplay -i s1-eth1 ${ppcapFile}.pcap" ENTER # Snort started with new config !
tmux detach -s runTraffic





