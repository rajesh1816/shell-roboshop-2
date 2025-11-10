#!/bin/bash

appname=rabbitmq
source ./common.sh
check_root
check_roboshop_user


cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copying rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling and starting the rabbitmq service"


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    echo -e "roboshop user not existed..$G so creating $N" 
    rabbitmqctl add_user roboshop $ROBOSHOP_PASSWORD
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
else
    echo -e "roboshop user alredy existed..$G so skipping $N"
fi
VALIDATE $? "creating user and password for rabbitmq"


print_time