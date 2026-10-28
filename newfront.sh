
#!/bin/bash

log_folder="/var/log/roboshop"
log_file="$log_folder/$(basename "$0").log"
user=$(id -u)
domain_name="kamesh.store"
script_folder="$(dirname "$(realpath "$0")")"

R="\e[31m"
G="\e[32m"
N="\e[0m"

mkdir -p "$log_folder"

timestamp() {
    date "+%F %T"
}

validation() {
    if [ "$1" -ne 0 ]; then
        echo -e "$(timestamp) =======[Error]======= $2..${R}Failed${N}" | tee -a "$log_file"
        exit 1
    else
        echo -e "$(timestamp) =======[Info]======= $2..${G}Success${N}" | tee -a "$log_file"
    fi
}

echo "Script started at :: $(timestamp)"

if [ "$user" -ne 0 ]; then
    echo -e "${R}Please run the script with root access!${N}"
    exit 1
fi

dnf module disable nginx -y &>> "$log_file"
validation $? "Disabling nginx module"

dnf module enable nginx:1.26 -y &>> "$log_file"
validation $? "Enabling nginx 1.26 module"

dnf install nginx -y &>> "$log_file"
validation $? "Installing nginx"

rm -rf /usr/share/nginx/html/*
validation $? "Removing default content"

curl -fL -o /tmp/frontend.zip \
    https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip \
    &>> "$log_file"
validation $? "Downloading frontend"

unzip -o /tmp/frontend.zip -d /usr/share/nginx/html \
    &>> "$log_file"
validation $? "Unzipping frontend"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_folder/roboshop.conf" \
    &>> "$log_file"
validation $? "Substituting domain"

cp "$script_folder/roboshop.conf" /etc/nginx/default.d/roboshop.conf \
    &>> "$log_file"
validation $? "Copying configuration"

nginx -t &>> "$log_file"
validation $? "Nginx configuration test"

systemctl enable nginx &>> "$log_file"
validation $? "Enabling nginx"

systemctl restart nginx &>> "$log_file"
validation $? "Restarting nginx"

echo "Script completed at :: $(timestamp)"
