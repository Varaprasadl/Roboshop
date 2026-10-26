#!/bin/bash

user_id=$(id -u)
log_folder="var/log/roboshop"
logfile="${log_folder}/@{0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



validate(){
    if [ $? -ne 0 ]; then
        echo "${1}..[Error] ${R}Failed{N}"
        else
        echo "${1}..[Info] ${R}Failed{N}"
    fi
}

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access"
    exit 1
fi

echo "Script started at : $(date +"%F %T")"

validate

