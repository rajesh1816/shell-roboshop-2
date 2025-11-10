#!/bin/bash

appname=frontend
source ./common.sh
check_root
check_roboshop_user

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx version"


dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling the nginx version"


dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing the nginx"


systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "enabling and starting the nginx"


rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default index.html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading nginx zip file"

cd /usr/share/nginx/html 
VALIDATE $? "changing directory to html folder"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping the nginx zip file"


cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying the our nginx conf file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restating the nginx"


print_time

