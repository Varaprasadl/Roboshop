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

dnf module disable nodejs -y   &>>   $log_file
dnf module enable nodejs:24 -y   &>>   $log_file
dnf install nodejs -y   &>>   $log_file
validation $? "nodejs installation"

node -v   &>>   $log_file
validation $? "nodejs installation"

#Knowing id is existed or not
id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validation $? "User add"
else
    echo -e "$(timestamp)=======[Info]======= catalog user already added..${Y}Skipping${N}"
fi  

#remvoing the old code
rm -rf /app
validation $? "removing old code"

mkdir -p /app
validation $? "Creating app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip   &>>   $log_file
validation $? "downloading catalogue"

cd /app
unzip /tmp/catalogue.zip   &>>   $log_file
validation $? "Unzipping catalogue"

npm install   &>>   $log_file
validation $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_folder/catalogue.service"

cp "$script_folder/catalogue.service" /etc/systemd/system/catalogue.service

systemctl daemon-reload &>>   $log_file
systemctl enable catalogue &>>   $log_file
systemctl start catalogue &>>   $log_file

validation $? "Load and start the service"

cp "$script_folder/mongo.repo" /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>   $log_file
validation $? "Install mongodb"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $log_file)
validation $? "Connecting to MongoDB"

if [ "$product_count" -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $log_file
    validation $? "Loading products"
else
    echo -e "$(timestamp) [INFO] Products are already loaded...${Y}SKIPPING${N}"
fi

systemctl restart catalogue
validation $? "Restarting Catalogue"