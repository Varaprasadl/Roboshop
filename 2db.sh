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

if [ $user_id -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

timestamp() {
                date "+%F %T"
            }


validation(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp)=======[Error]===${2}..${R}Failed${N}" | tee -a $log_file
        else
        echo -e "$(timestamp)=======[Info]===${2}..${G}Success${N}" | tee -a $log_file
    fi
    }

dnf module disable redis -y &>> $log_file
validation $? " dnf module disable redis -y step"


dnf module enable redis:7 -y &>> $log_file
validation $? " dnf module enable redis:7 -y step"

dnf install redis -y &>> $log_file
validation $? " dnf install redis -y step"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validation $? " sed step"

systemctl enable redis &>> $log_file
validation $? " systemctl enable redis step"

systemctl start redis &>> $log_file
validation $? " systemctl start redis step"

systemctl status redis &>> $log_file
validation $? " systemctl status redis step"

