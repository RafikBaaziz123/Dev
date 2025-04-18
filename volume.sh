#!/bin/sh

  create_volume()
  {
      local container_name="$1"

  case "$container_name" in
    "gladys_server")
      mkdir  /var/volgladys/logs /var/volgladys/db
      chmod 666 /var/volgladys/logs /var/volgladys/db
      ;;
    "matter_sdk")
      mkdir  /var/volmatter/matter_sdk /var/volmatter/logs
      chmod 666 /var/volmatter/matter_sdk /var/volmatter/logs
      ;;
    "meari_bridge")
      mkdir  /var/volmeari/logs
      chmod 666 /var/volmeari/logs
      ;;
    "mosquitto")
      mkdir  /var/volmosquitto/logs
      chmod 666 /var/volmosquitto/logs
      ;;
    "tb_gateway")
      mkdir  /var/voltb/config /var/voltb/extensions /var/voltb/logs
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
      rm -rf  /var/volgladys/
      ;;
    "matter_sdk")
      rm -rf  /var/volmatter/
      ;;
    "meari_bridge")
      rm -rf  /var/volmeari/
      ;;
    "mosquitto")
      rm -rf  /var/volmosquitto/
      ;;
    "tb_gateway")
      rm -rf /var/voltb/ 
      ;;
    *)
      echo "Unknown container: $container_name"
      ;;
  esac

    }
