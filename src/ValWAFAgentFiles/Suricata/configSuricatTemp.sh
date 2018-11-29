#!/bin/bash

ruleFileAgent=$1
sed -r "/placeholder/ s//$ruleFileAgent/g" ./ConfigRepo/suri_template.yaml > ./ConfigRepo/Suricata_${ruleFileAgent//.rules/}.yaml
