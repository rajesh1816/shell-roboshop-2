#!/bin/bash

appname=redis
source ./common.sh
check_root
check_roboshop_user



dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling redis default version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis 7 version"


dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "changing local connection to remote connection and disabling protected mode"


systemctl enable redis &>>$LOG_FILE
systemctl start redis 
VALIDATE $? "Enabling and starting mysql serice"


print_time
