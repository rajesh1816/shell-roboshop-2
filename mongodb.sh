#!/bin/bash

appname=mongodb
source ./common.sh
check_root
check_roboshop_user


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb on server"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "Enabling and starting the mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "changing Localhost ip to Remote connection"

systemctl restart mongod
VALIDATE $? "Restarting the mongodb server"