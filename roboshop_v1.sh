#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id=""


for instance in $@

do
    echo "$instance instance is installing"

    #Getting instance ID

    instance_id=$(aws ec2 run-instances \
                --image-id "$image_id" \
                --instance-type "$instance_type" \
                --security-groups "roboshop-common" "roboshop-$instance" \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
                )
    
    echo "Instance Id :: $instance_id"

    #Getting Public and private IP

    if [ "$instance" != "frontend"]; then
                id=$(aws ec2 describe-instances \
                    --instance-ids "$instance_id" \
                    --query 'Reservations[0].Instances[0].PublicIpAddress' \
                    --output text
                    )
        Route53="$instance.$domain_name"
        else
                id=$(aws ec2 describe-instances \
                    --instance-ids "$instance_id" \
                    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
                    --output text
                    )
        Route53="$domain_name"
    fi
    echo "Rote54 domain is $Route53"
done