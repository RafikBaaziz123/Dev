#!/bin/sh

put_config_tbgw()
{

    local TB_host="$1"
    local TB_port="$2"
    local config_file="/var/lib/lxc/tb_gateway/config"
    local backup_file="./bkp/config.bak"
    cp $config_file $backup_file
    #backup tbgateway file ...................
    #update tbgw config
    sed -i -E "s/^(TB_GW_HOST=).*/\1\$TB_host/" -E "s/^(TB_GW_PORT=).*/\1\$TB_port/" $config_file
    . ./utilities.sh
    
    lxc_restart "$container_name"
    sleep 15

    if  ! check_established_connection "tb_gateway" "$TB_host" ; then  
        #KO   
        cp $backup_file $config_file 
        lxc_restart "$container_name"
    fi
    rm $backup_file
   


}








