import subprocess

def restart_container(container_name):
    """Restart an LXC container using lxc_utilities.sh"""
    try:
        subprocess.run(f". ./lxc_utilities.sh && lxc_restart \"{container_name}\"", 
                      shell=True, check=True)
        print(f"Container {container_name} restarted successfully")
    except subprocess.CalledProcessError as e:
        print(f"Failed to restart container {container_name}: {e}")

restart_container("lxc" )