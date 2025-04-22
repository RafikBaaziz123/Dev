from utils import *

def setConfigTbGateway(payload):
    # initialize variables
    config_backup_path = "/home/ahmed/backup/mosquitto/config"
    config_path = "/var/lib/lxc/mosquitto/config"
    container = "mosquitto"
    true_response = {"success":"true"}
    false_response = {"success":"false"}
    run_command(f"cp {config_path} {config_backup_path}")
    # Extract values from payload
    payload = json.loads(payload)
    host = payload.get("host", "")
    port = payload.get("port", "")
    # Step 2: Update the configuration file
    try:
        with open(config_path, "r") as file:
            lines = file.readlines()

        with open(config_path, "w") as file:
            for line in lines:
                if line.startswith("lxc.environment = TB_GW_HOST"):
                    file.write(f"lxc.environment = TB_GW_HOST = {host}\n")
                elif line.startswith("lxc.environment = TB_GW_PORT"):
                    file.write(f"lxc.environment = TB_GW_PORT = {port}\n")
                else:
                    file.write(line)
         
        print("Configuration updated successfully.")

    except Exception as e:
        print(f"Error updating configuration: {e}")
    if(not run_command(f"lxc-stop -n {container}")):
        return false_response
    if(not run_command(f"lxc-start -n {container}")):
        return false_response
    return true_response    
    print("restart thingboard container finished")  
