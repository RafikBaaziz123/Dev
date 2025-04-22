#!/bin/sh

# Function to continuously ping until 10 consecutive successful pings are achieved
check_internet() {
    while true; do
        success_count=0  # Reset success count each time we check
        while [ "$success_count" -lt 5 ]; do
            if ping -W 1 -c 1 8.8.8.8 > /dev/null 2>&1; then
                success_count=$((success_count + 1))
                echo "Ping success $success_count/5"
            else
                # Reset success count on failure
                success_count=0
                echo "No internet connection. Retrying..."
            fi
            sleep 1  # Avoid rapid retries
        done

        if [ "$success_count" -ge 5 ]; then
            echo "Internet connection established. Proceeding..."
            break  # Exit the loop if connection is established
        else
            echo "Still no internet connection. Retrying..."
            sleep 5  # Wait a bit before retrying
        fi
    done
}

get_container_url() {
     local container_name="$1"
    # Check if file exists
    if [ ! -f "$csv_file" ]; then
        echo "Error: File $csv_file not found." >&2
        return 1
    fi
    # Read the CSV and find matching container
    container_url=$(grep "^$container_name," "$csv_file" | cut -d, -f2)
    # Check if URL was found
    if [ -z "$container_url" ]; then
        echo "Error: Container $container_name not found in $csv_file." >&2
        return 1
    else
        echo "$container_url"
        #return $container_url
    fi
}


put_container_url() {
     local container_url="$2"
    local container_name="$1"
    # Check if file exists
    if [ ! -f "$csv_file" ]; then
        echo "Error: File $csv_file not found." >&2
        return 1
    fi
    sed -i "s/^$container_name,[^,]*/$container_name,$container_url/" $csv_file
    echo "Updated container '$container_name' in '$csv_file'"

}

get_container_ip()
{
	local container_name="$1"
     # Check if file exists
    if [ ! -f "$csv_file" ]; then
        echo "Error: File $csv_file not found." >&2
        return 1
    fi
    # Read the CSV and find matching container
    container_ip=$(grep "^$container_name," "$csv_file" | cut -d, -f3)
    # Check if URL was found
    if [ -z "$container_ip" ]; then
        echo "Error: Container $container_name not found in $csv_file." >&2
        return 1
    else
        echo "$container_ip"
        #return $container_url
    fi

}



download_artifact() {
local container_name="$1"
url=$(get_container_url "$container_name")
  max_retries=5
  retry_delay=10
  retry_count=0
  while [ $retry_count -lt $max_retries ]; do
    echo "Attempt $((retry_count+1)) of $max_retries: Downloading $container_name..."
    http_code=$(curl -w "%{http_code}\n" -o "./tmp/$container_name.tar.xz" --insecure -s "$url")
    if [ "$http_code" -eq 200 ]; then
        echo "Download successful for $container_name."
        mkdir -p "./tmp/$container_name"
        tar -xf "./tmp/$container_name.tar.xz" -C "./tmp/$container_name"   
        return 0
    else
        retry_count=$((retry_count+1))
        echo "Download failed for $container_name. HTTP code: $http_code. Retry $retry_count of $max_retries."
        if [ $retry_count -lt $max_retries ]; then
            echo "Waiting $retry_delay seconds before next attempt..."
            sleep $retry_delay
        else
            echo "Maximum retries reached. Download for $container_name failed permanently."
            return 1
        fi
    fi
  done
}


download_config() {
local config_name="$1"
local config_path="$2"
url=$(get_container_url "$config_name")
  max_retries=5
  retry_delay=10
  retry_count=0
  while [ $retry_count -lt $max_retries ]; do
    mkdir -p "./tmp/$config_name"
    echo "Attempt $((retry_count+1)) of $max_retries: Downloading $config_name..."
    http_code=$(curl -w "%{http_code}\n" -o "./tmp/$config_name.tar.xz" --insecure -s "$url")
    if [ "$http_code" -eq 200 ]; then
        echo "Download successful for $config_name."
        tar -xf "./tmp/$config_name.tar.xz" -C "$config_path/$config_name"   
        return 0
    else
        retry_count=$((retry_count+1))
        echo "Download failed for $config_name. HTTP code: $http_code. Retry $retry_count of $max_retries."
        if [ $retry_count -lt $max_retries ]; then
            echo "Waiting $retry_delay seconds before next attempt..."
            sleep $retry_delay
        else
            echo "Maximum retries reached. Download for $config_name failed permanently."
            return 1
        fi
    fi
  done
}

check_established_connection() {
    local service="$1"
    local port="$2"
    if sudo netstat -nap | grep "$port"  | grep "$service" > /dev/null ; then
        return 0 
    fi
    return 1 
}
