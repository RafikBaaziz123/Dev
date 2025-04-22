from utils import *

def setDevice(payload):
    """Simulate setting device config."""
    return {"message": "Device configuration set"}

def getInfos(payload):
    """Collects all information into the required JSON format."""
    battery = get_battery_status()
    ssid, wifi_rssi = get_wifi_info()
    gsm_status, gsm_rssi = get_gsm_info()
    sim_status = get_sim_status()
    connection_type = get_connection_type()

    data = {
        "battery": battery,
        "ssid": ssid,
        "gsmConnectionStatus": gsm_status,
        "wifiConnectionStatus": "connected" if ssid != "not connected" else "disconnected",
        "connectionType": connection_type,
        "wifiRssi": wifi_rssi,
        "gsmRssi": gsm_rssi,
        "simCardNumber": sim_status,
        "threadModuleDefault": check_thread_status(),
        "bleModuleDefault": check_ble_status(),
        "wifiModuleDefault": "enabled" if os.path.exists("/sys/class/net/wlan0") else "disabled",
        "gsmModuleDefault": "enabled" if os.path.exists("/sys/class/net/wwan0") else "disabled",
        "powerDefault": check_power_status(),
        "lowBatteryDefault": check_low_battery(),
        "simCardNotInserted": "yes" if sim_status == "not inserted" else "no"
    }
    return data
        
#def getDeviceInfo(payload):
        
