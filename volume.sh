#!/bin/sh

container_name="$1"
echo "VOLUME $container_name"
case "$container_name" in
  "gladys_server")
    mkdir -p /var/volgladys/logs /var/volgladys/db
    chmod 666 /var/volgladys/logs /var/volgladys/db
    ;;
  "matter_sdk")
    mkdir -p /var/volmatter/matter_sdk /var/volmatter/logs
    chmod 666 /var/volmatter/matter_sdk /var/volmatter/logs
    ;;
  "meari_bridge")
    mkdir -p /var/volmeari/logs
    chmod 666 /var/volmeari/logs
    ;;
  "mosquitto")
    mkdir -p /var/volmosquitto/logs
    chmod 666 /var/volmosquitto/logs
    ;;
  "tb_gateway")
    mkdir -p /var/voltb/config /var/voltb/extensions /var/voltb/logs
    chmod 666 /var/voltb/config /var/voltb/extensions /var/voltb/logs
    ;;
  *)
    echo "Unknown container: $container_name"
    ;;
esac
