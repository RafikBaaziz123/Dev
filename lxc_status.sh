#!/bin/sh


check_lxc_running(){
    local container_name="$1"

      status=$(sudo lxc-info -n "$container_name" 2>/dev/null | grep '^State:' | awk '{print $2}')
    if [ "$status" = "RUNNING" ]; then
        return 0 
        else
        return 1
}

while IFS=',' read -r container_name _; do
. ./lxc_utilities.sh
if check_lxc_running "$container_name" = 1 ; then
    lxc_restart "$container_name"
done < "$csv_file"


check_running_process()
{
    . ./utilities.sh
    
    while IFS=',' read -r container_name _ container_ip; do

    mosquitto_sub -h get_container_ip "mosquitto" -p 1883 -t lxc/status/healthcheck/$container_name

done < "$csv_file"

}




checkLastActivityTimeTimeout()
{


    
}