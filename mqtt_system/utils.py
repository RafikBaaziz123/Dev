import json
import subprocess
import re
import os
import tarfile
import pylxd
import shutil
import requests
from requests.auth import HTTPBasicAuth

def publish_response(client, topic, response):
    """Publishes a response to the MQTT broker."""
    response_payload = json.dumps(response, indent=4)
    print(f"Publishing response to {topic}: {response_payload}")
    client.publish(topic, response_payload)
	    
def run_command(command):
    """Helper function to run shell commands."""
    try:
        subprocess.run(command, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        print(f"Failed to execute: {command}")
        return False

def check_all_running(status_dict):
    for key, value in status_dict.items():
        if value == "STOPPED":
            return False  # Breaks immediately and returns False
    return True  # Returns True if all values are not "STOPPED"
    
def check_all_destroyed(status_dict):
    for key, value in status_dict.items():
        if value == False:
            return False  # Breaks immediately and returns False
    return True  # Returns True if all values are not "STOPPED"    
   
def download_firmware(url, save_dir):
    """Download firmware .tar.gz from URL and save it in a specific directory."""
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    
    filename = os.path.basename(url)
    save_path = os.path.join(save_dir, filename)
    
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(save_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=1024):
                file.write(chunk)
        print(f"Firmware downloaded successfully: {save_path}")
        return filename
    else:
        raise Exception(f"Failed to download firmware: {response.status_code}")

def backup_container(container_name, backup_path):
    """Backup LXC container configuration."""
    config_path = f"/var/lib/lxc/{container_name}/config"
    if os.path.exists(config_path):
        shutil.copy(config_path, backup_path)
        print(f"Backup created: {backup_path}")
    else:
        raise FileNotFoundError("LXC container config not found.")

def extract_firmware(tar_dir, tar_filename, extract_dir):
    """Extract the downloaded .tar.xz file."""
    tar_path = os.path.join(tar_dir, tar_filename)
    
    if not os.path.isfile(tar_path):
        raise FileNotFoundError(f"The specified tar file does not exist: {tar_path}")
    
    if not os.path.exists(extract_dir):
        os.makedirs(extract_dir)
    
    try:
        with tarfile.open(tar_path, "r:xz") as tar:
            tar.extractall(path=extract_dir)
        print(f"Firmware extracted to: {extract_dir}")
    except tarfile.ReadError:
        raise Exception(f"Failed to extract firmware. The file may be corrupted or not a valid tar.xz: {tar_path}")
        
def create_container_from_rootfs(container_name, extract_dir):
    """Create an LXC container using lxc-create with rootfs.tar.xz and metadata.tar.xz."""
    rootfs_path = os.path.join(extract_dir, "rootfs.tar.xz")
    metadata_path = os.path.join(extract_dir, "meta.tar.xz")
    
    if not os.path.exists(rootfs_path) or not os.path.exists(metadata_path):
        raise FileNotFoundError("Required rootfs.tar.xz or metadata.tar.xz not found in extracted directory.")
    
    # Ensure old container is deleted
    #subprocess.run(["lxc-destroy", "-n", container_name, "-f"], check=False)
    
    # Create the container using rootfs and metadata
    subprocess.run(["lxc-create", "-n", container_name, "-t", "local", "--", "--metadata", metadata_path, "--fstree", rootfs_path], check=True)
    
    print(f"New LXC container {container_name} created from rootfs.tar.xz and metadata.tar.xz.")

def restore_config(container_name, backup_path):
    """Restore container configuration from backup."""
    config_path = f"/var/lib/lxc/{container_name}/config"
    if os.path.exists(backup_path):
        shutil.copy(backup_path, config_path)
        print(f"Configuration restored for: {container_name}")
    else:
        print("No backup config found. Using default config.")
        
def start_container(container_name):
    """Start the LXC container."""
    subprocess.run(["lxc-start", "-n", container_name], check=True)
    print(f"Container {container_name} started successfully.")
    
def destroy_container(container_name):
    """Destroy the LXC container."""
    subprocess.run(["lxc-destroy", "-n", container_name, "-f"], check=True)
    print(f"Container {container_name} destroyed successfully.")
    
    
#info utils
def get_battery_status():
    """Gets battery percentage (if applicable)."""
    battery_path = "/sys/class/power_supply/BAT0/capacity"
    try:
        if os.path.exists(battery_path):
            with open(battery_path, "r") as file:
                return int(file.read().strip())
        return "not available"
    except:
        return "unknown"

def get_wifi_info():
    """Gets the connected Wi-Fi SSID and signal strength (RSSI)."""
    try:
        ssid = subprocess.run(["iwgetid", "-r"], capture_output=True, text=True).stdout.strip()
        rssi_output = subprocess.run(["iwconfig", "wlan0"], capture_output=True, text=True).stdout
        rssi = None
        for line in rssi_output.split("\n"):
            if "Signal level" in line:
                rssi = int(line.split("Signal level=")[-1].split()[0].replace("dBm", ""))
                break
        return ssid if ssid else "not connected", rssi if rssi is not None else "unknown"
    except:
        return "unknown", "unknown"

def get_gsm_info():
    """Gets GSM connection status and signal strength (RSSI)."""
    try:
        result = subprocess.run(["mmcli", "-m", "0"], capture_output=True, text=True).stdout
        gsm_status = "connected" if "status: connected" in result else "disconnected"
        rssi = None
        for line in result.split("\n"):
            if "signal quality" in line:
                rssi = int(line.split(":")[-1].strip().replace("%", ""))
                break
        return gsm_status, rssi if rssi is not None else "unknown"
    except:
        return "unknown", "unknown"

def get_sim_status():
    """Checks if a SIM card is inserted."""
    try:
        result = subprocess.run(["mmcli", "-S"], capture_output=True, text=True).stdout
        return "inserted" if "SIM" in result else "not inserted"
    except:
        return "unknown"

def get_connection_type():
    """Determines if connected via Wi-Fi or GSM."""
    try:
        wifi_status = subprocess.run(["nmcli", "-t", "-f", "DEVICE,STATE", "device"], capture_output=True, text=True).stdout
        if "wlan0:connected" in wifi_status:
            return "Wi-Fi"
        elif "wwan0:connected" in wifi_status:
            return "GSM"
        return "unknown"
    except:
        return "unknown"

def check_thread_status():
    """Check if Thread module is enabled (wpan0 interface)."""
    try:
        result = subprocess.run(["ip", "link", "show"], capture_output=True, text=True).stdout
        return "enabled" if "wpan0" in result else "disabled"
    except:
        return "unknown"

def check_ble_status():
    """Check if Bluetooth (BLE) is enabled."""
    try:
        result = subprocess.run(["hciconfig"], capture_output=True, text=True).stdout
        return "enabled" if "hci0" in result else "disabled"
    except:
        return "unknown"

def check_power_status():
    """Check if the Raspberry Pi is running on external power or battery."""
    power_status_path = "/sys/class/power_supply/AC/online"
    try:
        if os.path.exists(power_status_path):
            with open(power_status_path, "r") as file:
                power_status = file.read().strip()
                return "stable" if power_status == "1" else "battery"
        return "unknown"
    except:
        return "unknown"

def check_low_battery():
    """Check if the battery level is low (if applicable)."""
    battery_path = "/sys/class/power_supply/BAT0/capacity"
    try:
        if os.path.exists(battery_path):
            with open(battery_path, "r") as file:
                battery_level = int(file.read().strip())
                return "yes" if battery_level < 20 else "no"
        return "not available"
    except:
        return "unknown"    
        
