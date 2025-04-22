#!/bin/sh
lxc_create(){
    local container_name="$1"    
    echo "create $container_name"
    sudo lxc-create -n "$container_name" -t local -- --metadata "./tmp/$container_name/meta.tar.xz" --fstree "./tmp/$container_name/rootfs.tar.xz" || {
    echo  "LXC container creation failed for $container_name."; exit 1;}
}   

lxc_start(){
    local container_name="$1"
    echo "start $container_name"
    lxc-start -n "$container_name"
}

lxc_stop(){
    local container_name="$1"
    echo "stop $container_name"
    lxc-stop -n "$container_name"
}

lxc_restart(){
    local container_name="$1"
    echo "stop $container_name"
    lxc-stop  "$container_name"
    echo "start $container_name"
    lxc-start -n "$container_name"
}

lxc_destroy(){
    local container_name="$1"
    echo "destroy $container_name"
    lxc-destroy -f -n "$container_name"
}


check_lxc(){
    local container_name="$1"
    sudo lxc-info -n "$container_name" >/dev/null 2>&1
}


reset_lxc(){
    local container_name="$1"
        
    lxc_destroy "$container_name"    
    if ["$container_name" == "matter_sdk"]; then
    
    . ./volume.sh 
    destroy_volume "$container_name"
    fi
}
