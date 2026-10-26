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
    echo "${R}Please run the script with root access!${N}"
    exit 1
fi

timestamp() {
                date "+%F %T"
            }


validation(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp)=======[Error]===${2}..${R}Failed${N}" | tee -a $log_file
        else
        echo -e "$(timestamp)=======[Info]===${2}..${G}Failed${N}" | tee -a $log_file
    fi
    }

cp mongo.repo /etc/yum.repos.d/mongo.repo
validation $? "Repo adding.."

dnf install mongodb-org -y
validation $? "mongo-db installation.."

systemctl enable mongod
systemctl start mongod
validation $? "enable&install.."

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validation $? "enable&install.."

systemctl restart mongod
validation $? "restart.."
