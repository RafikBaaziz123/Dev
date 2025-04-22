from utils import *

def reboot(payload):
    """Stop all LXC containers, send MQTT message, and reboot the system."""
    #initialize variables
    true_response = {"success": "true"}
    # Get list of running containers
    result = subprocess.run(["lxc-ls", "--quiet"], capture_output=True, text=True)
    containers = re.split(r'\s+', result.stdout.strip())  # Split by one or more spaces 
    for container in containers:
        if container:
            run_command(f"lxc-stop -n {container} --quiet ")        
    return true_response        
    #os.system("sudo reboot")

def reset(payload):
    #initialize variables
    db_path = "/var/volgladys/db/gladys-production.db"
    backup_path = "/home/ahmed/backup"
    db_filename = "gladys-production_backup.db"
    db_backup_path = os.path.join(backup_path, db_filename)
    status = {}
    true_response = {"success": "true"}
    false_response = {"success": "false"}
    #stop all containers
    result = subprocess.run(["lxc-ls", "--quiet"], capture_output=True, text=True)
    containers = re.split(r'\s+', result.stdout.strip())  # Split by one or more spaces
    for container in containers:
        if container:
            run_command(f"lxc-stop -n {container} --quiet ")     
    # delete all logs in /var/vol*
    #run_command("find /var/vol* -type f -name '*.log' -exec truncate -s 0 {} +")
    #run_command("find /var/vol* -type f -name '*.log' -exec delete -s 0 {} +")
    # Restore database in /var/volgladys/db
    #run_command(f"cp {db_backup_path} {db_path}")
    # Start all LXC containers one by one
    for container in containers:
        if container:
            status[container] = run_command(f"lxc-destroy -n {container}")
            #container_info = subprocess.run(["lxc-info", "-n", container, "-s"], capture_output=True, text=True)
            #state = container_info.stdout.strip().split(":")[-1].strip()
            #status[container] = state
    result = run_command("rm -rf /var/vol*")                            
    # Verify if all LXC containers are running
    if(check_all_destroyed(status) and result):
        return true_response
    else :
        return false_response 
        
