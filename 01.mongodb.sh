#!/bin/bash

user_id=$(id -u)
log_folder="var/log/roboshop"
logfile="${log_folder}/@{0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


if [ $user_id -ne 0 ]; then
    echo "Please use the root user access to install"
    exit 1
fi

