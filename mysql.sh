#!/bin/bash
appname=mysql
source ./common.sh
check_root
check_roboshop_user

echo "Enter mysql root password"
read -s SQL_ROOT_PASSWORD


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld 
VALIDATE $? "Enabling and stating the mysql service"

mysql_secure_installation --set-root-pass $SQL_ROOT_PASSWORD
VALIDATE $? "setting up sql root password"


print_time