#!/bin/bash

log_folder="var/log/roboshop"
log_file="$log_folder/${0}.log"
user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with root access!"
    exit 1
fi

mkdir -p $log_folder

timestamp() {
    date "+%F %T"
}

echo "Script stared time :: " $(timestamp)

validation() {
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) ==== [Error] ${2}.. ${R}Failed${N}" | tee -a $log_file
    else
        echo -e "$(timestamp) ==== [Info] ${2}.. ${G}Success${N}" | tee -a $log_file
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
validation $? "Adding Mongodb repo"


dnf install mongodb-org -y &>> $log_file
validation $? "Mongodb is installation"


systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validation $? "Mongodb is enabled & installed"
