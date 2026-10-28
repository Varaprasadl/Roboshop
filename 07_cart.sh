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

dnf module disable nodejs -y   &>> $log_file
dnf module enable nodejs:24 -y  &>> $log_file
dnf install nodejs -y   &>> $log_file
validation $? "Installing nodejs"


id roboshop   &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validation $? "App user adding"
else
    echo -e "(timestamp) =======[Info]====== App user already created ${Y}Skipping${N}"
fi

rm -rf /app   &>> $log_file
validation $? "Removing old code"

mkdir -p /app   &>> $log_file
validation $? "Adding App directory"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip   &>> $log_file
validation $? "Downloading code"

cd /app
unzip /tmp/cart.zip   &>> $log_file
validation $? "Unzipping code"

cd /app
npm install   &>> $log_file
validation $? "installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_folder/cart.service"   &>> $log_file
cp "$script_folder/cart.service" /etc/systemd/system/cart.service   &>> $log_file
validation $? "Configuring systemD service"

systemctl daemon-reload   &>> $log_file
systemctl enable cart   &>> $log_file
systemctl start cart   &>> $log_file
validation $? "enable & start cart"

