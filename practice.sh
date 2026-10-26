#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id="Z10354933NXAGMDA0K5ZW"
user_id=$(id -u)
log_folder="var/log/roboshop"
log_file="$log_folder/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p "$log_folder"
timestamp() {
                date "+%F %T"
            }


for instance in $@

do
    instance_id=$(aws ec2 run-instances \
  --image-id "$image_id" \
  --instance-type "$instance_type" \
  --security-groups "roboshop-common" "roboshop-$instance" \
  --count 1 \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

  echo "$instance ID :: $instance_id"
validation $? "Instance creation"

  validation(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp)=======[Error]===${2}..${R}Failed${N}" | tee -a $log_file
        else
        echo -e "$(timestamp)=======[Error]===${2}..${R}Failed${N}" | tee -a $log_file
    fi
    }




done