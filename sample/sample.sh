#!/bin/bash

export INSTANCE_NUM=3

export AMI_ID=ami-xxxxxxxx
export SECURITY_GROUP_IDS=sg-xxxxxxxx
export SUBNET_ID=subnet-xxxxxxxx

# https://github.com/tsenart/vegeta#attack
export VEGETA_CMD='echo "GET http://target/" | vegeta attack -rate=100 -duration=30s'

sh run.sh 