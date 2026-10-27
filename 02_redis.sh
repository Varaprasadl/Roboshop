#!/bin/bash

log_folder="var/log/roboshop"
log_file="$log_folder/${0}.log"
user=$(id -u)
domain_name="kamesh.store"
script_folder="$(dirname $(realpath ${0}))"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $log_folder

timestamp() {
    date "+%F %T"
}

validation() {
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp)=======[Error]=======${2}..${R}Failed${N}" | tee -a $log_file
        exit 1
    else
        echo -e "$(timestamp)=======[Info]=======${2}..${G}Success${N}" | tee -a $log_file
    fi
}

echo "Script started at :: $(timestamp)"


if [ $user -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

dnf module disable redis -y    &>>   $log_file
dnf module enable redis:7 -y    &>>   $log_file
dnf install redis -y    &>>   $log_file
validation $? "redis installation"

sed -i -e 's/^bind 127.0.0.1 -::1/bind 0.0.0.0 -::1/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

systemctl enable redis   &>>   $log_file
systemctl start redis   &>>   $log_file
validation $? "redis enable & start"   &>>   $log_file


systemctl status redis    &>>   $log_file

echo "Script completed at :: $(timestamp)"
echo "Script run time :: ${SECONDS} seconds"


