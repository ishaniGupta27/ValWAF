#!/bin/bash
file_name=$1

sudo tcpdump -U -n tcp dst port 80 -w ${file_name}.pcap
