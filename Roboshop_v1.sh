#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
domain_name="kamesh.store"
hosted_zone_id=""

for instance in $@

do

    echo "$Instance: is created"
    aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "t3.micro" \
        --security-group-ids Roboshop-common, Roboshop-"$Instance" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Roboshop"$Instance"}]'\
        --query 'Instances[0].InstanceId' \
        --output text


done