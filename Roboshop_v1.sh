#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
domain_name="kamesh.store"
hosted_zone_id="ff"

for instance in $@

do

    echo "Creating $instance"
    aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "t3.micro" \
        --security-group-ids Roboshop-common, Roboshop-"$instance" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-'$instance'}]'\
        --query 'Instances[0].InstanceId' \
        --output text


done