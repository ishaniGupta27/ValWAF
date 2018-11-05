# WebApplicationFirewall
Building a Web Application Firewall by deploying state-of-art Deep Packet Inspection techniques

Setup till Now

1. Snort Setup
    1. Add rules in /etc/snort/rules: alias rules : Myrules.rules
    2. /etc/snort/snort.conf : Add above rules files as include ….
2. Ryu Controller Setup 
    1. Ryu app : isha_snort
3. Start Mininet : topo_new
4. Start Ryu
    1. ./ryustart.sh isha_snort
5. Start Snort
    1. sudo snort -i s1-eth1 -c /etc/snort/snort.conf -A unsock -N -l /tmp
6. Next Step : Start working on the pcap file and see what snort rules we can work on
    1. sudo tcpreplay -i veth0 [pcap-file]
    2. Find pcap-file
    3. Work on snort ruels
    4. Watch video to see how to do analysis on snort !!
