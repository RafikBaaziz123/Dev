#!/bin/sh


init_config()
{
	local  container_name="$1"	
    local config_file="/var/lib/lxc/$container_name/config"
    . ./utilities.sh
    . ./variables.env
    local container_ip=$(get_container_ip "$container_name")

    if [ -z "$container_name" ]; then
        echo "Usage: $0 <container_name>"
        exit 1
    fi

    echo "Configuring network and environment variables for container: $container_name"

    case "$container_name" in
        "gladys_server")
            echo $tb_gateway_config >> "$config_file"
sed -i "s|^lxc\.net\.0\.ipv4\.address =.*|lxc.net.0.ipv4.address = ${container_ip//\//\\/}|" "$config_file"
#             cat <<EOF >> "$config_file"
# lxc.net.0.ipv4.address = "$container_ip"
# lxc.environment = MOSQUITTO_URL=mqtt://10.0.3.12:1883
# lxc.environment = SQLITE_FILE_PATH=./db/gladys-production.db
# EOF
            ;;
        "matter_sdk")
            echo $matter_sdk_config >> "$config_file"
sed -i "s|^lxc\.net\.0\.ipv4\.address =.*|lxc.net.0.ipv4.address = ${container_ip//\//\\/}|" "$config_file"
#             cat <<EOF >> "$config_file"
# lxc.net.0.ipv4.address = "$container_ip"
# EOF
            ;;
        "meari_bridge")
            # Modify gateway and configure additional network interface
            sed -i '/^lxc.net.0.ipv4.gateway = auto/ c\#lxc.net.1.ipv4.gateway = auto' "$config_file"
            sed -i '/^lxc.net.0.type = veth/ c\lxc.net.1.type = veth' "$config_file"
            sed -i '/^lxc.net.0.link = lxcbr0/ c\lxc.net.1.link = lxcbr0' "$config_file"
            sed -i '/^lxc.net.0.flags = up/ c\lxc.net.1.flags = up' "$config_file"
            echo $meari_bridge_config >> "$config_file"

#             cat <<EOF >> "$config_file"
# lxc.net.1.ipv4.address = "$container_ip"
# lxc.net.0.type = veth
# lxc.net.0.link = br-wan
# lxc.net.0.flags = up
# lxc.net.0.ipv4.gateway = 192.168.2.1
# lxc.net.0.ipv4.address = 192.168.2.5/24
# lxc.environment = CAMERA_ID=004e977f1d3a475a
# EOF
            ;;
        "mosquitto")
            echo $mosquitto_config >> "$config_file"
sed -i "s|^lxc\.net\.0\.ipv4\.address =.*|lxc.net.0.ipv4.address = ${container_ip//\//\\/}|" "$config_file"
#             cat <<EOF >> "$config_file"
# lxc.net.0.ipv4.address = "$container_ip"
# EOF
            ;;
        "tb_gateway")
            echo $tb_gateway_config >> "$config_file"
sed -i "s|^lxc\.net\.0\.ipv4\.address =.*|lxc.net.0.ipv4.address = ${container_ip//\//\\/}|" "$config_file"		    host_mac_address=$(cat /sys/class/net/ens4/address)
     
#             cat <<EOF >> "$config_file"
# lxc.net.0.ipv4.address = "$container_ip"
# lxc.environment = TB_GW_ACCESS_TOKEN= "$host_mac_address"
# lxc.environment = TB_GW_HOST=thingsboard.dev.protectline.fr
# lxc.environment = TB_GW_PORT=1884
# EOF
            ;;
        *)
            echo "Unknown container: $container_name"
            exit 1
            ;;
    esac

    echo "Configuration for $container_name applied successfully."
}
