#!/bin/sh

container_name="$1"
doRecreate="$2"

init_lxc(){
    . ./utilities.sh
    
    download_artifact "$container_name"
    
    . ./lxc_utilities.sh
    
    lxc_create "$container_name"

    . ./default_config_lxc.sh 
    init_config "$container_name"

    lxc_start "$container_name"
    if [ "$container_name" = "matter_sdk" ]; then
        # . ./open_thread.sh
        # THREAD_CRED=$(OTBR_GET_CREDS)
        # nohup ./matter.sh "$THREAD_CRED" & 
        echo "run thread2"
    fi
}

cleanup(){
    rm -rf "./tmp/$container_name" 
}

# Check if container exists
. ./lxc_utilities.sh
. ./volume.sh
if check_lxc "$container_name"; then
    if [ "$doRecreate" = true ]; then 
    echo "recreate $doRecreate"
        lxc_destroy "$container_name"
        destroy_volume "$container_name"
        init_lxc
        cleanup "$container_name"

    fi
else 
    init_lxc
    cleanup "$container_name"
fi 



