#!/bin/bash

ruleFileAgent=$1


#stop snort
#cd /etc/init.d
#./snort stop

#move orig config file to temp
#mv /etc/snort/snort.conf /etc/snort/snort.conf_orig

#pick template and add the rules name in it
sed -r "/placeholder/ s//$ruleFileAgent/g" ./conf_template > ./ConfRepo/Snort_$ruleFileAgent.conf

#START SNORT
#cd /etc/init.d
#./snort start

