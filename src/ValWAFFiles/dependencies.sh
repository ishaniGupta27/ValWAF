#!/bin/bash
sudo apt-get update
sudo apt-get install python
sudo apt install g++
sudo apt install python-pip
pip install exrex
sudo apt-get install libcurl4-openssl-dev
g++ -std=c++11 MaliciousTrafficGenerator/idsEventGenerator.cpp -lcurl