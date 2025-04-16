#!/bin/sh

put_config_tbgw()
{

    local host="$1"
    local port="$2"
    local config_file="/var/lib/lxc/tb_gateway/config"


    #backup tbgateway file ...................
    #update tbgw config
    sed -i -E "s/^(TB_GW_HOST=).*/\1\$host/" -E "s/^(TB_GW_PORT=).*/\1\$port/" $config_file
    
}

./default_config_lxc.sh "$container_name"
if $container_name="tb_gateway" ; then 
    put_config_tbgw "host" "port"


    . ./utilities.sh
    
    lxc_restart "$container_name"
    sleep 15

    if  ! check_established_connection "mosquitto" "1883" ; then 
        echo "error"
        #restore backup gateway config
        #remove backupfile
    fi

    fi










