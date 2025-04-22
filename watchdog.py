import csv
import os
import subprocess
import json
import time
import paho.mqtt.client as mqtt
import os
def load_env_file(file_path):
    """
    Load environment variables from a file.
    Args:
        file_path (str): Path to the .env file
    Returns:
        dict: Dictionary of loaded variables (also added to os.environ)
    """
    
    with open(file_path) as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
            
            # Split on first '=' only
            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip().strip("'\"")
                
                # Store in both dictionary and environment
                os.environ[key] = value
                
    

def check_LXC_UP(csv_file):
    """
    Check if LXC containers are up by subscribing to MQTT topics.
    If a container is up but has timed out, restart it.
    """
    # Read containers from CSV file
    with open(csv_file, 'r') as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            if not row:
                continue
                
            container_name = row[0]
            print(f"Checking container: {container_name}")
            
            # Create a new client for each container to avoid message overlap
            client = mqtt.Client()
            #env varibles are set in the bash_rc file

            #print (type(os.environ.get("broker_ip")), os.environ.get("broker_port"))
            client.connect(os.environ.get("broker_ip"), int(os.environ.get("broker_port")), 60)
            
            topic = f"lxc/status/healthcheck/{container_name}"
            messages = []
            
            # Define message handler specific to this container
            def on_message(client, userdata, msg):
                if msg.topic == topic:  # Only process messages for this specific topic
                    payload = msg.payload.decode('utf-8')
                    try:
                        data = json.loads(payload)
                        messages.append(data)
                        print(f"Received for {container_name}: {payload}")
                    except json.JSONDecodeError:
                        print(f"Invalid JSON received for {container_name}: {payload}")
            
            # Set up and start the client
            client.on_message = on_message
            client.subscribe(topic)
            client.loop_start()
            
            # Wait for up to 30 seconds for a message
            timeout = 30
            start_time = time.time()
            while not messages and time.time() - start_time < timeout:
                time.sleep(0.1)
            
            # Clean up - unsubscribe and stop the loop
            client.unsubscribe(topic)
            client.loop_stop()
            client.disconnect()
            
            # Process the received message if any
            if messages and "status" in messages[0] and messages[0]["status"] == "UP":
                timeout_value = check_last_activity_time_timeout(container_name)
                print(f"Container {container_name} is UP, timeout value: {timeout_value}")
                if timeout_value == 0:
                    # Restart container
                    print(f"Restarting container {container_name}")
                    restart_container(container_name)
                else:
                    put_last_activity_time_timeout(container_name)
            else:
                print(f"No valid status message received for {container_name}")

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
    print(f"Updated timeout for {container_name}")

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
    ('variables.env')        
    check_LXC_UP(os.environ.get('csv_file'))