
#!/bin/sh

container="$1"
SUP_LOG="./logs/status.log"
datetime=$(date '+%Y-%m-%d %H:%M:%S')

check_container() {
  local container_name="$1"
  local status

  # Get the container state
  status=$(sudo lxc-info -n "$container_name" 2>/dev/null | grep '^State:' | awk '{print $2}')
  if [ "$status" = "STOPPED" ]; then
      echo "$datetime: Problem detected. Container $container_name is STOPPED." >> "$SUP_LOG"
      return 0
  else
      echo "$datetime: Container $container_name is running well." >> "$SUP_LOG"
      return 1
  fi
}

# Main execution
if [ -z "$container" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

if   check_container "$container"; then

	echo "$datetime: $container is not running. Restarting..." >> "$SUP_LOG"
	sudo lxc-start -n "$container" >> "$SUP_LOG" 2>&1
	echo "starting conatiner : $container "  >> "$SUP_LOG"
fi


