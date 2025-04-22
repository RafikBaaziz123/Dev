from utils import *
from config import *

def getFirmwares(payload):
    """Fetch firmware versions of the host and containers."""
    version_data = {}
    base_path = "/var/lib/lxc"
    try:
        with open("/etc/version", 'r') as file:
            version_data["host"] = file.read().strip()
    except Exception as e:
        version_data["host"] = f"Error: {str(e)}"

    result = subprocess.run(["lxc-ls", "--quiet"], capture_output=True, text=True)
    containers = re.split(r'\s+', result.stdout.strip())

    for container in containers:
        if container:
            version_path = os.path.join(base_path, container, "rootfs/etc/version")
            try:
                with open(version_path, "r") as f:
                    version_data[container] = f.read().strip()
            except FileNotFoundError:
                version_data[container] = "Error: Version file not found"
            except PermissionError:
                version_data[container] = "Error: Permission denied"
            except Exception as e:
                version_data[container] = f"Error: {str(e)}"

    return version_data
    
def putFirmware(payload):
    try:
        data = json.loads(payload)
        url = data["url"]
        container_type = data["type"]
        old_container = f"{container_type}"
        new_container = f"{container_type}"
        backup_path = f"/var/tmp/config.backup"
        firmware_dir = "/var/tmp"
        extract_dir = f"/var/tmp/{container_type}_extracted"

        # Step 1: Backup old container config
        backup_container(old_container, backup_path)
        print("backup container done")
        # Step 2: Destroy old container
        destroy_container(old_container)
        print("container destroyed")        
        # Step 3: Download firmware and get filename
        tar_filename = download_firmware(url, firmware_dir)
        
        # Step 4: Extract firmware
        extract_firmware(firmware_dir, tar_filename, extract_dir)
        
        # Step 5: Create new container from extracted rootfs and metadata
        create_container_from_rootfs(new_container, extract_dir)
        
        # Step 6: Restore config to new container
        restore_config(new_container, backup_path)
        
        # Step 7: Start new container
        start_container(new_container)
        return TRUE_RESPONSE
    except Exception as e:
        print(f"Upgrade failed: {e}")
        return FALSE_RESPONSE     
