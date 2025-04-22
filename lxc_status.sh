#!/bin/sh
check_lxc_running(){
ù
    while IFS=',' read -r container_name _; do

      status=$(sudo lxc-info -n "$container_name" 2>/dev/null | grep '^State:' | awk '{print $2}')
    if ! [ "$status" = "RUNNING" ]; then
            lxc_start "$container_name"
    fi
    done < "$csv_file"
    sleep 60
}

check_running_process()
{
    python3 watchdog.py

}

checkLastActivityTimeTimeout()
{


    
}