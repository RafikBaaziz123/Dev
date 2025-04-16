#!/bin/sh
mkdir ./logs 2>/dev/null
mkdir ./tmp 2>/dev/null
csv_file="./containers_urls.csv"

    while IFS=',' read -r container_name _ container_ip; do
      mkdir -p "./tmp/$container_name"

    done < "$csv_file"




