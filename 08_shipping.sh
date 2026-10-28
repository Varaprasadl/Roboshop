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

dnf module enable maven:3.9 -y   &>> $log_file
dnf install maven java-25-openjdk-devel -y   &>> $log_file
validation $? "Installing java & maven"

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"  &>> $log_file
validation $? "Updating java25"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validation $? "Setting Java_home for maven"


java -version
mvn -v
validation $? "Version checking"

id roboshop  &>> $log_file
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validation $? "Adding App user"
else
    echo -e "$(timestamp) ======= [Info] ======= User already added ${Y}Skipping${N}"
fi

rm -rf /app   &>> $log_file
validation $? "Old code removing"

mkdir /app   &>> $log_file
validation $? "App dir creation"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip   &>> $log_file
validation $? "Downloading code"

cd /app
unzip /tmp/shipping.zip   &>> $log_file
validation $? "Unzipping code"

cd /app
mvn clean package   &>> $log_file
mv target/shipping.jar shipping.jar    &>> $log_file
validation $? "Installing dependiences"

dnf install mysql -y    &>> $log_file
validation $? "Installing mysql"

Count=$(mysql -u username -p -e "SELECT COUNT(*) FROM database_name.table_name;")   &>> $log_file

if [ -z "$count" ] || [ "$count" -ne 0 ]; then
    mysql -h "shipping.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql    &>> $log_file
    validation $? "DB connection"
else
    echo "DB already loaded"
fi

mysql -h "shipping.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql   &>> $log_file
validation $? "My SQL conneted"

sed -i "s/DOMAIN_NAME/.$domain_name/g" "$script_folder/shipping.service"   &>> $log_file
cp "$script_folder/shipping.service" /etc/systemd/system/shipping.service   &>> $log_file


systemctl daemon-reload   &>> $log_file
systemctl enable shipping   &>> $log_file
systemctl start shipping   &>> $log_file

validation $? "Shipping enable & start"







