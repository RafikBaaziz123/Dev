#!/bin/sh

csv_file="./containers_params.csv"

while IFS=',' read -r container_name _; do
    # Check if the file exists
    if [ ! -f "./wdg/$container_name" ]; then
        echo "Error: ./wdg/$container_name file not found!"
        exit 1
    fi

    # Read the value from the file
    value=$(cat "./wdg/$container_name")

    # Check if the value is a number
    if ! echo "$value" | grep -qE '^[0-9]+$'; then
        echo "Error: The content of ./wdg/$container_name is not a valid number!"
        exit 1
    fi

    # Decrement the value by 1
    new_value=$((value - 1))

    # Write the new value back to the file
    echo "$new_value" > "./wdg/$container_name"

    echo "Value decremented from $value to $new_value"
done < "$csv_file"