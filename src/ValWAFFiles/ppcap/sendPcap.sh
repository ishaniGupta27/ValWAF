#!/bin/bash
file_name=$1
valAgent=$2

scp -i netproj.pem ${file_name}.pcap ubuntu@${valAgent}:WebApplicationFirewall/src/ValWAFAgentFiles/trafficRepo/