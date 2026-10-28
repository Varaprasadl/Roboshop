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

dnf install python3.14 python3.14-pip -y
python3.14 --version
validation $? "python installed"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validation $? "Application user adding"
else
    echo -e "$(timestamp)========[Info]========App user already added${Y}Skipping${N}"
fi

rm -rf /app
validation $? "Removing old code"

mkdir -p /app
validation $? "App directory creation"

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip
validation $? "Downloading code"

cd /app
unzip /tmp/payment.zip
validation $? "Unzipping code"


cd /app
python3.14 -m venv /app/.venv
/app/.venv/bin/pip install -r requirements.txt
validation $? "Installing dependiencies"

sed "s/DOMAIN_NAME/$domain_name/g" "$script_folder/payment.service"
cp "$script_folder/payment.service" /etc/systemd/system/payment.service

systemctl daemon-reload
systemctl enable payment
systemctl start payment

validation $? "Payment enable & start"






