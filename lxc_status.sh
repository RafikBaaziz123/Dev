#!/bin/sh


check_lxc_running(){
    local container_name="$1"
    # local csv_file="./containers_params.csv"

      status=$(sudo lxc-info -n "$container_name" 2>/dev/null | grep '^State:' | awk '{print $2}')
    if ! [ "$status" = "RUNNING" ]; then
        
    while IFS=',' read -r container_name _; do
        . ./lxc_utilities.sh
        if ! check_lxc_running "$container_name"; then
            lxc_restart "$container_name"
        fi
    done < "$csv_file"

        
    fi
}


check_running_process()
{
   python3 watchdog.py

}




checkLastActivityTimeTimeout()
{


    
}