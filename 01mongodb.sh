#!/bin/bash

log_folder="var/log/roboshop"
log_file="$log_folder/${0}.log"
user_id=$(id -u)

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
        echo "$(timestamp) ==== [Error] ${2}.. Failed"
    else
        echo "$(timestamp) ==== [Info] ${2}.. Success"
    fi
}

echo "Script completed " $(timestamp)
validate $? Function