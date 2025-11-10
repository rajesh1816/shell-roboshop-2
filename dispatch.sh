#!/bin/bash

source ./common.sh
appname=dispatch

check_root
check_roboshop_user
app_setup
go_setup

systemd_setup

print_time





