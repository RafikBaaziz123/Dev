#!/bin/sh

set -e  # Exit on errors

DAEMON_LOG="./logs/init_script.log"
url="$1"
container="$2"
datetime=$(date '+%Y-%m-%d %H:%M:%S')

log_message() {
    echo "$datetime: $1" >> "$DAEMON_LOG"
}

download_program() {
    log_message "Downloading $container from $url."
    # Perform the download and capture the HTTP status code

    http_code=$(curl -w "%{http_code}\n" -o "./tmp/$container.tar.xz" --insecure -s "$url")
    if [ "$http_code" -eq 200 ]; then
        log_message "Download successful for $container."
        return 0
    else
        log_message "Download failed for $container. HTTP code: $http_code"
        return 1
    fi
}

check_download() {
    if download_program; then
	echo "	Download of $container completed successfully."
        log_message "Download of $container completed successfully."
    else
	echo "fail to install $container"
        log_message "Download of $container failed."
        exit 1
    fi
}

# Main execution
if [ -z "$container" ] || [ -z "$url" ]; then
    echo "Usage: $0 <container_name> <url>"
    exit 1
fi

check_download

# Create and extract the container directory
mkdir -p "./tmp/$container"

tar -xf "./tmp/$container.tar.xz" -C "./tmp/$container" || { log_message "Extraction failed for $container."; exit 1; }
echo "create $container"
# Create and start the LXC container
sudo lxc-create -n "$container" -t local -- --metadata "./tmp/$container/meta.tar.xz" --fstree "./tmp/$container/rootfs.tar.xz" || {
    log_message "LXC container creation failed for $container."; exit 1;
}

./network_config.sh "$container"

echo "start $container"
    lxc-start -n "$container" || {
    log_message "LXC container start failed for $container."; exit 1;
}

log_message "LXC container $container started successfully."
#remove container artifacts
rm -rf "./tmp/$container*" 
