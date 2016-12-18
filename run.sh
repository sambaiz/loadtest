#!/bin/bash

# Example

# INSTANCE_NUM=3
# AMI_ID=ami-xxxxxxxx
# SECURITY_GROUP_IDS=sg-xxxxxxxxz
# SUBNET_ID=subnet-xxxxxxxx
# VEGETA_CMD='echo "GET http://target/" | vegeta attack -rate=100 -duration=30'

# Clean up (after finished or aborted)

INSTANCE_IDS=
PUBLIC_DNS_NAMES=

cleanup() {
  echo "---- Clean up ----"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
  aws ec2 delete-key-pair --key-name LoadTestKeyPare
  rm -f LoadTestKeyPare.pem
  rm $PUBLIC_DNS_NAMES
}
trap cleanup EXIT SIGHUP SIGINT SIGQUIT SIGTERM

# Prepare

echo "---- Prepare ----"

aws ec2 create-key-pair --key-name LoadTestKeyPare --query 'KeyMaterial' --output text > LoadTestKeyPare.pem

chmod 400 LoadTestKeyPare.pem

EC2_RES=`aws ec2 run-instances --image-id $AMI_ID --count $INSTANCE_NUM --instance-type t2.micro --key-name LoadTestKeyPare --security-group-ids $SECURITY_GROUP_IDS --subnet-id $SUBNET_ID`
INSTANCE_IDS=`echo $EC2_RES | jq -r '.Instances[].InstanceId'`
echo "INSTANCE_IDS: $INSTANCE_IDS"

echo "Wait until instance status ok"
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_IDS

PUBLIC_DNS_NAMES=`aws ec2 describe-instances --instance-ids $INSTANCE_IDS | jq -r '.Reservations[].Instances[].PublicDnsName'`
echo "PUBLIC_DNS_NAMES: $PUBLIC_DNS_NAMES"

# Run

echo "---- Run ----"

if [ -n "$RESOURCES_DIR" ]; then
    for machine in $PUBLIC_DNS_NAMES; do
        scp -r -i ./LoadTestKeyPare.pem -oStrictHostKeyChecking=no $RESOURCES_DIR ec2-user@$machine:~/
    done
fi

export PDSH_SSH_ARGS_APPEND='-i ./LoadTestKeyPare.pem -oStrictHostKeyChecking=no'
pdsh -l ec2-user -w `echo "$PUBLIC_DNS_NAMES" |  paste -d, -s -` "$VEGETA_CMD > result.bin"

for machine in $PUBLIC_DNS_NAMES; do
  scp -i ./LoadTestKeyPare.pem -oStrictHostKeyChecking=no ec2-user@$machine:~/result.bin $machine
done

vegeta report -inputs=`echo $PUBLIC_DNS_NAMES |  paste -d, -s -` 
vegeta report -reporter=plot -inputs=`echo $PUBLIC_DNS_NAMES |  paste -d, -s -` > result.html 
