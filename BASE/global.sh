#!/bin/sh

url1="https://base-rootfs.s3.eu-west-3.amazonaws.com/matter-sdk/matter-sdk-1.3-master-015933e78abce1eea684cc711be30133bded61db.tar.xz"
url2="https://base-rootfs.s3.eu-west-3.amazonaws.com/mosquitto/mosquitto-latest-master.tar.xz"
url3="https://base-rootfs.s3.eu-west-3.amazonaws.com/gladys-server/gladys-server-4.51.0-develop-4ed1c40cf3606f16c82ddd2f2ce683f6a1187be5.tar.xz"
url4="https://base-rootfs.s3.eu-west-3.amazonaws.com/meari-bridge/meari-bridge-0.1-master-015933e78abce1eea684cc711be30133bded61db.tar.xz"

container1="matter_sdk"
container2="mosquitto"
container3="gladys_server"
container4="meari_bridge"

# Initialize success count
success_count=0

# # Function to continuously ping until 10 consecutive successful pings are achieved
# check_internet() {
#     while true; do
#         success_count=0  # Reset success count each time we check
#         while [ "$success_count" -lt 5 ]; do
#             if ping -W 1 -c 1 8.8.8.8 > /dev/null 2>&1; then
#                 success_count=$((success_count + 1))
#                 echo "Ping success $success_count/5"
#             else
#                 # Reset success count on failure
#                 success_count=0
#                 echo "No internet connection. Retrying..."
#             fi
#             sleep 1  # Avoid rapid retries
#         done

#         if [ "$success_count" -ge 5 ]; then
#             echo "Internet connection established. Proceeding..."
#             break  # Exit the loop if connection is established
#         else
#             echo "Still no internet connection. Retrying..."
#             sleep 5  # Wait a bit before retrying
#         fi
#     done
# }


# Function to initialize containers with a given URL
initialize_containers() {
    while [ "$#" -gt 1 ]; do
        url="$1"
        container="$2"
        shift 2  # Shift to the next IP and container pair
	#if container doesnt exist then create  
	if ! lxc-ls "$container" | grep -q "$container"; then
        echo "Initializing $container with URL $url and IP $ip_address"
        ./volume_create.sh "$container"
        if [ "$container" = "matter_sdk" ]; then
            ./init.sh "$url" "$container"
            sudo mount --bind /var/lib/lxc/matter_sdk/rootfs/matter_sdk /var/volmatter/matter_sdk
            systemctl daemon-reload
	    nohup ./matter.sh "/var/volmatter/matter_sdk" "$THREAD_CREDENTIALS" "/var/volmatter/logs/matter_setup.log" &
        else
            ./init.sh "$url" "$container"
	fi
	fi
    done
}

# Define containers and URL
# mkdir ./logs
# mkdir ./tmp 2>/dev/null
#shut down the wlan interface and create bridged interface
./bridge_network_config.sh 2>/dev/null

# #add config if don't exist
# grep -qxF "lxc.net.0.ipv4.gateway = auto" /etc/lxc/default.conf || echo "lxc.net.0.ipv4.gateway = auto" >> /etc/lxc/default.conf

check_internet
#OTBR
#export THREAD_CREDENTIALS=$(./otbr.sh | sed '$d')
export THREAD_CREDENTIALS=$(./otbr.sh | grep -oE '[0-9a-fA-F]{2,}' | tail -n 1)
# Example usage
#initialize_containers "$url1" "$container1" "$url2" "$container2" "$url3" "$container3" "$url4" "$container4" "$url5" "$container5"
#initialize_containers "$url1" "$container1" "$url2" "$container2" "$url3" "$container3" "$url4" "$container4"
initialize_containers "$url1" "$container1"

    # Endlessly loop to check the status for the containers
    while true; do
        #for container in "$container1"  "$container2"  "$container3"  "$container4"  ; do
        for container in "$container1" ; do
            ./status.sh "$container"

        done
        # Sleep to free the CPU
        sleep 1
    done
