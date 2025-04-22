#!/bin/sh

  create_volume()
  {
      local container_name="$1"
  case "$container_name" in
    "gladys_server")
      mkdir  /tmp/volgladys/logs /var/volgladys/db
      chmod 666 /tmp/volgladys/logs /var/volgladys/db
      ;;
    "matter_sdk")
      mkdir  /var/volmatter/matter_sdk /tmp/volmatter/logs
      chmod 666 /var/volmatter/matter_sdk /tmp/volmatter/logs
      ;;
    "meari_bridge")
      mkdir  /tmp/volmeari/logs
      chmod 666 /tmp/volmeari/logs
      ;;
    "mosquitto")
      mkdir  /tmp/volmosquitto/logs
      chmod 666 /tmp/volmosquitto/logs
      ;;
    "tb_gateway")
      mkdir  /var/voltb/config /var/voltb/extensions /tmp/voltb/logs
      chmod 666 /var/voltb/config /var/voltb/extensions /tmp/voltb/logs
      . ./utilities.sh
      download_config $container_name "/var/voltb/config"
      ;;
    *)
      echo "Unknown container: $container_name"
      ;;
  esac
  }


  destroy_volume_matter()
  {
      local container_name="$1"

  case "$container_name" in
    "matter_sdk")
      rm -rf  /var/volmatter/
      ;;
    *)
      echo "Unknown container: $container_name"
      ;;
  esac

    }
