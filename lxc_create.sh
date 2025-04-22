#!/bin/sh

container_name="$1"
doRecreate="$2"

init_lxc(){

    . ./lxc_utilities.sh
    lxc_create "$container_name"
    . ./lxc_config.sh 
    init_config "$container_name"
    lxc_start "$container_name"
    if [ "$container_name" = "matter_sdk" ]; then
        # nohup ./matter.sh & 
        echo "run thread2"
    fi
}

cleanup(){
    rm -rf "./tmp/$container_name*" 
}
# Check if container exists
. ./lxc_utilities.sh
. ./volume.sh
if ! check_lxc "$container_name"; then
    # First-time setup if container doesn't exist
    init_lxc
    cleanup "$container_name"
    exit 0  # Skip the rest of the script
fi

# Only proceed if container exists and recreation is requested
if [ "$doRecreate" != true ]; then
    exit 0
fi

echo "Recreating container: $container_name"
lxc_destroy "$container_name"

# Conditionally destroy volumes (only for matter_sdk)

destroy_volume_matter "$container_name"

# Common steps for recreation
. ./utilities.sh
download_artifact "$container_name"
init_lxc
cleanup "$container_name"