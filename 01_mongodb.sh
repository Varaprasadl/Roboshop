#!/bin/bash

log_folder="/var/log/roboshop"
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

cp "$script_folder"/mongo.repo /etc/yum.repos.d/mongo.repo     &>>   $log_file
validation $? "mongodb repo adding"

dnf install mongodb-org -y   &>>   $log_file
validation $? "mongodb installation"

systemctl enable mongod   &>>   $log_file
systemctl start mongod    &>>   $log_file
validation $? "mongodb enable & start "

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validation $? "mongodb configuration file update"

systemctl restart mongod   &>>   $log_file
validation $? "mongodb restart"

echo "Script completed at :: $(timestamp)"
echo "Script run time :: ${SECONDS} seconds"

systemctl status mongod &>>   $log_file













