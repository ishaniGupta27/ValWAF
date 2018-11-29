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
scp -i ${pemFile} ${pemFileAgent} ubuntu@${valWaf}:/home/ubuntu/WebApplicationFirewall/src/ValWAFFiles/ppcap/pemToOrg.pem

#tmux for starting server
tmux -2 new-session -d -s startServer
tmux send -t startServer " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER
tmux send -t startServer "  sudo python -m SimpleHTTPServer 80 &" ENTER
tmux detach -s startServer

sleep 10

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
tmux send -t maliciousTrafficGenerator " ./make_ppcap.sh $ruleFile $valWaf" ENTER

sleep 10
#stop tracking traffic
tmux send -t maliciousTrafficGenerator " ./stopTracking.sh" ENTER
#send file to ValWAFAgent
tmux detach -s maliciousTrafficGenerator

sleep 5


#tmux kill-session -t startServer
#tmux kill-session -t trackTraffic
#tmux kill-session -t maliciousTrafficGenerator




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
tmux -2 new-session -d -s reconfigSuricata
tmux send -t reconfigSuricata " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t reconfigSuricata "  cd WebApplicationFirewall/src/ValWAFAgentFiles/Suricata/" ENTER #
tmux send -t reconfigSuricata " ./configSuricatTemp.sh ${ruleFileAgent}" ENTER # New config : src/ValWAFAgentFiles/ConfiRepo 
tmux detach -s reconfigSuricata

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
#tmux kill-session -t reconfigSuricata

tmux -2 new-session -d -s runSuricata
tmux send -t runSuricata " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t runSuricata "  cd WebApplicationFirewall/src/ValWAFAgentFiles" ENTER #
tmux send -t runSuricata "./suricatastart.sh ${ruleFileAgent//.rules/}" ENTER # Suricata started with new config !
tmux detach -s runSuricata

echo 'Suricata starting '

sleep 10 #it takes time for snort to start. Depend on rules?
tmux -2 new-session -d -s runTraffic
tmux send -t runTraffic " ssh -i ${pemFileAgent} ubuntu@${valAgent} " ENTER
tmux send -t runTraffic "  cd WebApplicationFirewall/src/ValWAFAgentFiles/trafficRepo" ENTER #
tmux send -t runTraffic "sudo tcpreplay -i s1-eth1 ${ppcapFile}.pcap" ENTER # Snort started with new config !
tmux detach -s runTraffic

echo 'Logs generating '

sleep 30 #it takes time for runnigntraffic and generatign logs


echo 'exiting org system..  '

#stop mininet & snort & ryu controller
tmux send -t startSimulator:1 " exit" ENTER

#sending logs back to engine in ValWAF
sleep 10


echo 'fetching logs...  '
tmux -2 new-session -d -s fetchLogsForEngine
tmux send -t fetchLogsForEngine " ssh -i ${pemFile} ubuntu@${valWaf} " ENTER #went to ValWAF
tmux send -t fetchLogsForEngine " cd  WebApplicationFirewall/src/ValWAFFiles/Engine/Alllogs" ENTER
#tmux send -t fetchLogsForEngine " scp -i ../../ppcap/pemToOrg.pem ubuntu@${valAgent}:/home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/stdlogs.txt   ./ " ENTER
tmux send -t fetchLogsForEngine " scp -r -i ../../ppcap/pemToOrg.pem ubuntu@${valAgent}:/home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/Suricata/logs  ./ " ENTER

#moved the logs to older version for future reference  
sleep 10

tmux send -t runTraffic "  cd ../" ENTER #
tmux send -t runTraffic "  mv -f  stdlogs.txt stdlogs_old.txt" ENTER #
tmux send -t runTraffic "  mv -rf logs/* old_logs/" ENTER #








