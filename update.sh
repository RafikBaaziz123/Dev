#!/bin/bash

# Get MAC address of ens4 interface

MAC_ADDRESS=$(cat /sys/class/net/$network_interface/address )

check_update_orchestrator() {
    echo "Checking for orchestrator updates..."
    # Download the version file using MAC address in header
    curl --header "mac: ${MAC_ADDRESS}" -O https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/orchestrator_version.csv
    
    if [ ! -f orchestrator_version.csv ]; then
        echo "Failed to download version file"
        return 1
    fi
    # Read remote version into variable
    new_version=$(cat orchestrator_version.csv)
 
    local_version=$(cat versions/orchestrator_version)
    if [$(compare_versions "$new_version" "$local_version" ) == 1] : then 
        update_orchestrator
    fi
}



compare_versions() {
datetime=$(date "+%Y_%m_%d-%H:%M") 
    ver1=$1
    ver2=$2
    # Validate version formats
    if ! (echo "$ver1" | grep -qE '^[0-9]+(\.[0-9]+)*$') || ! (echo "$ver2" | grep -qE '^[0-9]+(\.[0-9]+)*$'); then
    echo "$datetime: Error - Invalid version format: $ver1 or $ver2"
    return 3
    fi
    
    if [ "$ver1" = "$ver2" ]; then
        return 0
    fi

    while true; do
        ver1_first=$(echo "$ver1" | cut -d '.' -f 1)
        ver1=${ver1#"$ver1_first"}
        ver1=${ver1#.}

        ver2_first=$(echo "$ver2" | cut -d '.' -f 1)
        ver2=${ver2#"$ver2_first"}
        ver2=${ver2#.}

        if [ "${ver1_first:-0}" -gt "${ver2_first:-0}" ]; then
            echo "$datetime : remote $3 is newer."   
            return 1
        elif [ "${ver1_first:-0}" -lt "${ver2_first:-0}" ]; then
            return 2 
        else 
            if [ -z "$ver1" ] && [ -z "$ver2" ]; then
              continue
            fi
        fi  
    done
}




check_md5() {
    local orchestrator_md5_url="$1"
    local orchestrator_file_md5="$2"
    #TODO need url to get checksum from
  local_md5=$(cat "$orchestrator_file_md5" )
  remote_md5=$(curl --header "mac: ${MAC_ADDRESS}" -s "$orchestrator_md5_url" | awk '{print $1}')
  if [ "$remote_md5" == "$local_md5" ]; then  
          tar -xzf /tmp/orchestrator.tar.gz -C /root --overwrite
          echo "$datetime : Daemon has been updated successfully." 
    else
        echo "$datetime : Daemon checksums are different aborting." 
    fi
    
}
update_orchestrator() {

    echo "Updating orchestrator..."
    # Download the orchestrator package
    orchestrator_url="https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/orchestrator.tar.gz"
    orchestrator_url_checksum="https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/orchestrator.md5"
    curl --header "mac: ${MAC_ADDRESS}" -o /tmp/orchestrator.tar.gz $orchestrator_url
    if [ ! -f orchestrator.tar.gz ]; then
        echo "Failed to download orchestrator package"
        return 1
    fi
    check_md5 "$orchestrator_url_checksum" "$orchestrator_file_md5" 
    # For now, we'll just update the version file
    cat orchestrator_version.csv > versions/orchestrator_version
    echo "Updated to version $version"
}

white_list_vpn() {
    echo "Checking VPN whitelist..."
    
    # Download the whitelist file
    curl --header "mac: ${MAC_ADDRESS}" -O https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/openvpn_whitelist.csv
    
    if [ ! -f openvpn_whitelist.csv ]; then
        echo "Failed to download VPN whitelist"
        return 1
    fi
    
    # Check if MAC address exists in whitelist
    if grep -q "$MAC_ADDRESS" openvpn_whitelist.csv; then
        echo "MAC address $MAC_ADDRESS is in the whitelist"
        connect_openvpn
    else
        echo "MAC address $MAC_ADDRESS is not in the whitelist"
    fi
}

connect_openvpn() {
    echo "Connecting to OpenVPN..."

    # openvpn --config /etc/openvpn/client.conf
}

# Main script execution can start here
# Uncomment the functions you want to run
# check_update_orchestrator
# white_list_vpn