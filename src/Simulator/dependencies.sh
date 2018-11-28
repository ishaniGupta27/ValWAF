#!/bin/bash

sudo apt-get update
sudo apt-get install git

#install mininet
git clone git://github.com/mininet/mininet
cd mininet
~/mininet/util/install.sh -a

#test mininet
sudo mn --test pingall --topo single,3

#install ryu controller
sudo apt-get install -y python-pip
git clone git://github.com/osrg/ryu.git
cd ryu; pip install .

#prepare system for snort
sudo apt-get install openssh-server ethtool build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev
sudo apt-get install libluajit-5.1-2 libluajit-5.1-common libluajit-5.1-dev luajit
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
tar xvzf daq-2.0.6.tar.gz                  
cd daq-2.0.6
./configure && make && sudo make install

#install snort
wget https://www.snort.org/downloads/snort/snort-2.9.12.tar.gz
tar xvzf snort-2.9.12.tar.gz
cd snort-2.9.12
./configure --enable-sourcefire && make && sudo make install

#install tcpreplay
sudo apt-get install tcpreplay



