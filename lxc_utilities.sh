#!/bin/sh
lxc_create(){
    local container_name="$1"

    
    echo "create $container_name"
    sudo lxc-create -n "$container_name" -t local -- --metadata "./tmp/$container_name/meta.tar.xz" --fstree "./tmp/$container/rootfs.tar.xz" 
        
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
   
        lxc-destroy -n "$container_name"
}


check_lxc(){
    local container_name="$1"
    sudo lxc-info -n "$container_name" >/dev/null 2>&1

}


reset_lxc(){
    local container_name="$1"
    lxc_destroy $container_name
    lxc_create $container_name
    lxc_start $container_name

    
}








