#!/bin/bash
pid=$(ps -e | pgrep tcpdump)
echo $pid

sleep 5
sudo kill -2 $pid
