#!/bin/sh



csv_file="./containers_params.csv"
# Check if file exists
if [ ! -f "$csv_file" ]; then
    echo "Error: File $csv_file not found." >&2
    return 1
fi

#run for all LXCs
while IFS=',' read -r container_name _; do
echo "$container_name"

. ./volume.sh 
create_volume "$container_name"

./lxc_create.sh "$container_name" "false"
done < "$csv_file"

