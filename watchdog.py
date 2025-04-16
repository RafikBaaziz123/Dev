import csv
import os
import subprocess
import json
import time
import paho.mqtt.client as mqtt

def check_LXC_UP(csv_file):
    """
    Check if LXC containers are up by subscribing to MQTT topics.
    If a container is up but has timed out, restart it.
    """
    # MQTT client setup
    client = mqtt.Client()
    client.connect("localhost", 1883, 60)
    
    # Read containers from CSV file
    with open(csv_file, 'r') as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            if not row:
                continue
                
            container_name = row[0]
            topic = f"lxc/status/healthcheck/{container_name}"
            
            # Subscribe to the topic and wait for a message
            messages = []
            
            def on_message(client, userdata, msg):
                payload = msg.payload.decode('utf-8')
                messages.append(json.loads(payload))
            
            client.on_message = on_message
            client.subscribe(topic)
            client.loop_start()
            
            # Wait for up to 5 seconds for a message
            timeout = 5
            start_time = time.time()
            while not messages and time.time() - start_time < timeout:
                time.sleep(0.1)
            
            client.loop_stop()
            
            # Process the received message if any
            if messages and "status" in messages[0] and messages[0]["status"] == "UP":
                timeout_value = check_last_activity_time_timeout(container_name)
                if timeout_value == 0:
                    # Restart container
                    restart_container(container_name)
                else:
                    put_last_activity_time_timeout(container_name)
    
    # Disconnect MQTT client
    client.disconnect()

def restart_container(container_name):
    """Restart an LXC container using lxc_utilities.sh"""
    try:
        subprocess.run(f". ./lxc_utilities.sh && lxc_restart \"{container_name}\"", 
                      shell=True, check=True)
        print(f"Container {container_name} restarted successfully")
    except subprocess.CalledProcessError as e:
        print(f"Failed to restart container {container_name}: {e}")

def put_last_activity_time_timeout(container_name):
    """
    Write timeout values to watchdog files.
    For mosquitto container: 60 seconds
    For all other containers: 120 seconds
    """
 
    # Create or empty the file
    file_path = f"wdg/{container_name}"
    with open(file_path, 'w') as file:
        # Write appropriate timeout value
        if container_name == "mosquitto":
            file.write("60")
        else:
            file.write("120")

def check_last_activity_time_timeout(container_name):
    """
    Read the timeout value from the watchdog file.
    Returns the timeout value or 0 if file doesn't exist or is empty.
    """
    file_path = f"wdg/{container_name}"
    
    try:
        with open(file_path, 'r') as file:
            content = file.read().strip()
            return int(content) if content else 0
    except (FileNotFoundError, ValueError):
        return 0

# Example usage
if __name__ == "__main__":
    check_LXC_UP("containers_params.csv")