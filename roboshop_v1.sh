#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id=""


for instance in $@

do
    echo "$instance instance is installing"

    instance_id=$(aws ec2 run-instances \
                --image-id ami-0055977a6e828a4f4 \
                --instance-type t3.micro \
                --security-groups roboshop-common \
                --count 1 \
                --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="shell"}]' \
                --query 'Instances[0].InstanceId' \
                --output text
                )
    
    echo "Instance Id :: $instance_id"

done