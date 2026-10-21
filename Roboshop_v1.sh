#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
domain_name="kamesh.store"
hosted_zone_id="ff"

for instance in $@

do

    echo "Creating $instance"
    instance_id=$(aws ec2 run-instances \
                        --image-id "$ami_id" \
                        --instance-type "t3.micro" \
                        --security-group-ids Roboshop-Common Roboshop-"$instance" \
                        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-'$instance'}]'\
                        --query 'Instances[0].InstanceId' \
    )
    echo "Instance ID :: $instance_id"

        if [$instance_id != "frontend"]; then
                    IP=$(aws ec2 describe-instances \
                    --instance-ids "$ami_id" \
                    --query "Reservations[*].Instances[*].PrivateIpAddress" \
                    --output text)
                route53_record="$Instance.$domain_name"
            else
                    IP=$(aws ec2 describe-instances \
                    --instance-ids "$ami_id" \
                    --query "Reservations[*].Instances[*].PublicIpAddress" \
                    --output text)
                route53_record="$domain_name"                
        fi    
    echo "route53_record is:: $route53_record"

done