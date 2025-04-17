#!/bin/bash

# Get MAC address of ens4 interface
MAC_ADDRESS=$(ip link show ens4 | grep -o 'link/ether [^ ]*' | cut -d' ' -f2)

check_update_orchestrator() {
    echo "Checking for orchestrator updates..."
    
    # Download the version file using MAC address in header
    curl --header "mac: ${MAC_ADDRESS}" -O https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/orchestrator_version.csv
    
    if [ ! -f orchestrator_version.csv ]; then
        echo "Failed to download version file"
        return 1
    fi
    
    # Read remote version into variable
    version=$(cat orchestrator_version.csv)
    
    # Read local version
    if [ ! -f versions/orchestrator_version ]; then
        echo "Local version file not found"
        mkdir -p versions
        echo "0" > versions/orchestrator_version
    fi
    
    local_version=$(cat versions/orchestrator_version)
    
    # Compare versions
    if [ "$version" == "$local_version" ]; then
        echo "Orchestrator is up to date (version: $local_version)"
    else
        echo "New version available: $version (current: $local_version)"
        update_orchestrator
    fi
}

update_orchestrator() {
    echo "Updating orchestrator..."
    
    # Download the orchestrator package
    curl --header "mac: ${MAC_ADDRESS}" -O https://lxc-volumes.s3.eu-west-3.amazonaws.com/orchestrator/orchestrator.tar.gz
    
    if [ ! -f orchestrator.tar.gz ]; then
        echo "Failed to download orchestrator package"
        return 1
    fi
    
    # TODO: check md5 and update the version
    
    # For now, we'll just update the version file
    version=$(cat orchestrator_version.csv)
    echo "$version" > versions/orchestrator_version
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
    # Add your OpenVPN connection logic here
    # For example:
    # openvpn --config /etc/openvpn/client.conf
}

# Main script execution can start here
# Uncomment the functions you want to run
# check_update_orchestrator
# white_list_vpn