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

timestamp() {
    date "+%F %T"
}

echo "Script stared time :: " $(timestamp)

validation() {
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) ==== [Error] ${2}.. ${R}Failed${N}"
    else
        echo -e "$(timestamp) ==== [Info] ${2}.. ${Y}Success${N}"
    fi
}

echo "Script completed " $(timestamp)
validation $? Function

