#!/bin/bash

sudo apt install g++
sudo apt-get install libcurl4-openssl-dev
g++ -std=c++11 MaliciousTrafficGenerator/idsEventGenerator.cpp -lcurl