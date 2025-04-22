#!/bin/sh


. ./open_thread.sh
THREAD_CRED=$(OTBR_GET_CREDS)
sudo mount --bind /var/lib/lxc/matter_sdk/rootfs/matter_sdk /var/volmatter/matter_sdk
systemctl daemon-reload
python3 -m venv /var/volmatter/matter_sdk/ && .  /var/volmatter/matter_sdk/bin/activate && pip install gmqtt  && pip install paho-mqtt && pip install -r /var/volmatter/matter_sdk/setup/requirements.txt && cd /var/volmatter/matter_sdk/setup && export MOSQUITTO_URL=10.0.3.12 && export MOSQUITTO_PORT=1883 &&  export LOG_PATH="/var/volmatter/logs/matter_setup.log"  && export THREAD_CREDENTIALS="$THREAD_CRED" && python3  /var/volmatter/matter_sdk/matter.py 
