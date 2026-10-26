#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id="Z10354933NXAGMDA0K5ZW"
user_id=$(id -u)
log_folder="var/log/roboshop"
log_file="$log_folder/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


mkdir -p "$log_folder"

if [ $user_id -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

timestamp() {
                date "+%F %T"
            }


validation(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp)=======[Error]===${2}..${R}Failed${N}" | tee -a $log_file
        else
        echo -e "$(timestamp)=======[Info]===${2}..${G}Success${N}" | tee -a $log_file
    fi
    }

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validation $? "Copy step"

dnf install erlang rabbitmq-server -y &>>$log_file
validation $? "dnf install erlang rabbitmq-server -y step"


systemctl enable rabbitmq-server &>>$log_file
validation $? "systemctl enable rabbitmq-server step"

systemctl start rabbitmq-server &>>$log_file
validation $? "systemctl start rabbitmq-server step"


rabbitmqctl add_user roboshop roboshop123  &>>$log_file
validation $? "add_user step"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$log_file
validation $? "set_permissions step"


rabbitmq-plugins enable rabbitmq_management  &>>$log_file
validation $? "enable rabbitmq_management step"

rabbitmqctl set_user_tags roboshop administrator  &>>$log_file
validation $? "set_user_tags roboshop administrator step"


rabbitmq-plugins enable rabbitmq_management &>>$log_file
validation $? "enable rabbitmq_management step"

rabbitmqctl set_user_tags roboshop administrator  &>>$log_file
validation $? "set_user_tags step"

