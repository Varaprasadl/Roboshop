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
        echo -e "$(timestamp)=======[Error]======= ${2}..${R}Failed${N}" | tee -a $log_file
        exit 1
    else
        echo -e "$(timestamp)=======[Info]======= ${2}..${G}Success${N}" | tee -a $log_file
    fi
}

echo "Script started at :: $(timestamp)"


if [ $user -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

dnf module disable nodejs -y
dnf module enable nodejs:24 -y
dnf install nodejs -y
validation $? "nodejs installation"

node -v
validation $? "nodejs installation"


