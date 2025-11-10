#!/bin/bash

appname=user
source ./common.sh

check_root
app_setup
nodejs_setup

systemd_setup

print_time

