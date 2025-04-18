#!/bin/sh
mkdir ./logs 2>/dev/null
mkdir ./tmp 2>/dev/null
mkdir ./bkp 2>/dev/null
mkdir ./cron 2>/dev/null
mkdir ./wdg 2>/dev/null

. ./variables.env

echo $rotate_config > /etc/cron.d/rotate.conf


    while IFS=',' read -r container_name _ container_ip; do
      mkdir -p "./tmp/$container_name"
    done < "$csv_file"




