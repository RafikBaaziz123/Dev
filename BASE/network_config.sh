#!/bin/sh

matter_sdk="10.0.3.13/24"
mosquitto="10.0.3.12/24"
gladys_server="10.0.3.10/24"
meari_bridge="10.0.3.14/24"
tb_gateway="10.0.3.11/24"

container="$1"
config_file="/var/lib/lxc/$container/config"
host_mac_address=$(cat /sys/class/net/eth0/address)




if [ -z "$container" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

echo "Configuring network and environment variables for container: $container"

case "$container" in
  "gladys_server")
    cat <<EOF >> "$config_file"
lxc.net.0.ipv4.address = $gladys_server
lxc.environment = MOSQUITTO_URL=mqtt://10.0.3.12:1883
lxc.environment = SQLITE_FILE_PATH=./db/gladys-production.db
EOF
    ;;
  "matter_sdk")
    cat <<EOF >> "$config_file"
lxc.net.0.ipv4.address = $matter_sdk
EOF
    ;;
  "meari_bridge")
    # Modify gateway and configure additional network interface
    sed -i '/^lxc.net.0.ipv4.gateway = auto/ c\#lxc.net.1.ipv4.gateway = auto' "$config_file"
    sed -i '/^lxc.net.0.type = veth/ c\lxc.net.1.type = veth' "$config_file"
    sed -i '/^lxc.net.0.link = lxcbr0/ c\lxc.net.1.link = lxcbr0' "$config_file"
    sed -i '/^lxc.net.0.flags = up/ c\lxc.net.1.flags = up' "$config_file"
    cat <<EOF >> "$config_file"
lxc.net.1.ipv4.address = $meari_bridge
lxc.net.0.type = veth
lxc.net.0.link = br-wan
lxc.net.0.flags = up
lxc.net.0.ipv4.gateway = 192.168.2.1
lxc.net.0.ipv4.address = 192.168.2.5/24
lxc.environment = CAMERA_ID=004e977f1d3a475a
EOF
    ;;
  "mosquitto")
    cat <<EOF >> "$config_file"
lxc.net.0.ipv4.address = $mosquitto
EOF
    ;;
  "tb_gateway")
    cat <<EOF >> "$config_file"
lxc.net.0.ipv4.address = $tb_gateway
lxc.environment = TB_GW_ACCESS_TOKEN= $host_mac_address
EOF
    ;;
  *)
    echo "Unknown container: $container"
    exit 1
    ;;
esac

echo "Configuration for $container applied successfully."
