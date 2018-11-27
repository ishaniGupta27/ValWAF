#!/bin/bash
file_name=$1


scp -i netproj.pem ${file_name} ubuntu@35.180.39.78:/home/ubuntu/WebApplicationFirewall/ppcap
