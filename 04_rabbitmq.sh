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

cp "$script_folder"/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo   &>>   $log_file
validation $? "rabbitmq repo file adding"

dnf install erlang rabbitmq-server -y   &>>   $log_file
validation $? "rabbitmq installation"

systemctl enable rabbitmq-server   &>>   $log_file
systemctl start rabbitmq-server   &>>   $log_file
validation $? "rabbitmq enable&start"

rabbitmqctl user_list | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123   &>>   $log_file
    validation $? "rabbitmq add user"
else
    echo -e "$(timestamp)=======[Info]======= Rabbitmq already exists..${Y}Skipping${N}" | tee -a $log_file
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"   &>>   $log_file
validation $? "rabbitmq set permissions"


echo "Script completed at :: $(timestamp)"
echo "Script run time :: ${SECONDS} seconds"
