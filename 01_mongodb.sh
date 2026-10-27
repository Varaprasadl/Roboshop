#!/bin/bash

log_folder="/var/log/roboshop/"
log_file="$log_folder/${0}.log"
user=$(id -u)
domain_name="kamesh.store"
script_folder="$(dirname $(realpath ${0}))"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timestamp() {
    date "+%F %T"
}

echo "Script started time :: $(timestamp)"

mkdir -p $log_file

if [ $user -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

validation() {
    if [ $1 -ne 0 ]; then
        echo "$(timestamp)=======[Error]=======${2}..${R}Failed${N}" | tee -a $log_file
    else
        echo "$(timestamp)=======[Info]=======${2}..${G}Success${N}" | tee -a $log_file
    fi
}

cp "$script_folder"/mongo.repo /etc/yum.repos.d/mongo.repo
validation $? "mongo repo adding"

dnf install mongodb-org -y
validation $? "mongo installation"







