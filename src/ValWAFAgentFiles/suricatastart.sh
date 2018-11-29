#!/bin/bash
conf=$1
sudo suricata -D -k none --pidfile /home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/Suricata/pidfile -c /home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/Suricata/ConfigRepo/Suricata_${conf}.yaml -i s1-eth1 -l /home/ubuntu/WebApplicationFirewall/src/ValWAFAgentFiles/Suricata/logs 
