#!/bin/bash

export INSTANCE_NUM=3

export AMI_ID=ami-xxxxxxxx
export SECURITY_GROUP_IDS=sg-xxxxxxxx
export SUBNET_ID=subnet-xxxxxxxx

export RESOURCES_DIR=res

# https://github.com/tsenart/vegeta#attack
export VEGETA_CMD='vegeta attack -targets=res/targets.txt -rate=100 -duration=10s'

sh run.sh 