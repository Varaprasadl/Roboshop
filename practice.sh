#!/bin/bash

image_id="AKIA4Q3LLMDSILZ6B2B6"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id="Z10354933NXAGMDA0K5ZW"

for instance in $@

do
    instance_id=$(aws ec2 run-instances \
  --image-id "$image_id" \
  --instance-type "$domain_name" \
  --security-groups "roboshop-common" "roboshop-$instance" \
  --count 1 \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

  echo "$instance_id"
  

done