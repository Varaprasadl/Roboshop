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


dnf module disable nodejs -y
dnf module enable nodejs:24 -y
dnf install nodejs -y
node -v
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validation $? "Step"

mkdir /app
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip
cd /app
unzip /tmp/catalogue.zip
mkdir /app
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip
cd /app
unzip /tmp/catalogue.zip
validation $? "Step"

cp catalogue.service /etc/systemd/system/catalogue.service
validation $? "Step"

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y
validation $? "Step"


mongosh --host 0.0.0.0 </app/db/master-data.js

mongosh --host 0.0.0.0 --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()'
validation $? "Step"

systemctl status catalogue
journalctl -u catalogue -f
curl http://localhost:8080/health
curl http://localhost:8080/products
validation $? "Step"
