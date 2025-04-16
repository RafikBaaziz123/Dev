#!/bin/sh

  create_volume()
  {
      local container_name="$1"

  case "$container_name" in
    "gladys_server")
      rm -rf  /var/volgladys/logs /var/volgladys/db
      chmod 666 /var/volgladys/logs /var/volgladys/db
      ;;
    "matter_sdk")
      rm -rf  /var/volmatter/matter_sdk /var/volmatter/logs
      chmod 666 /var/volmatter/matter_sdk /var/volmatter/logs
      ;;
    "meari_bridge")
      rm -rf  /var/volmeari/logs
      chmod 666 /var/volmeari/logs
      ;;
    "mosquitto")
      rm -rf  /var/volmosquitto/logs
      chmod 666 /var/volmosquitto/logs
      ;;
    "tb_gateway")
      rm -rf  /var/voltb/config /var/voltb/extensions /var/voltb/logs
      chmod 666 /var/voltb/config /var/voltb/extensions /var/voltb/logs
      ;;
    *)
      echo "Unknown container: $container_name"
      ;;
  esac
  }


  destroy_volume()
  {
      local container_name="$1"

  case "$container_name" in
    "gladys_server")
      rm -rf  /var/volgladys/logs /var/volgladys/db
      ;;
    "matter_sdk")
      rm -rf  /var/volmatter/matter_sdk /var/volmatter/logs
      ;;
    "meari_bridge")
      rm -rf  /var/volmeari/logs
      ;;
    "mosquitto")
      rm -rf  /var/volmosquitto/logs
      ;;
    "tb_gateway")
      rm -rf -p /var/voltb/config /var/voltb/extensions /var/voltb/logs
      ;;
    *)
      echo "Unknown container: $container_name"
      ;;
  esac

    }
