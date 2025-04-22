import re
from api.firmware import getFirmwares, putFirmware
from api.device import setDevice, getInfos
from api.logs import getLogs
from api.gateway import setConfigTbGateway
from api.system import reset, reboot
from utils import publish_response

def handle_command(client, topic, payload):
    match = re.match(r"gateway/request/mqtt_(\w+)/(\d+)", topic)  # Extract API command and requestId
    if match:
        command, request_id = match.groups()
        response_topic = f"gateway/response/mqtt_{command}/{request_id}"

        if command == "getFirmwares":
            print("get firmware command")
            publish_response(client, response_topic, getFirmwares(payload))
        elif command == "putFirmware":
            publish_response(client, response_topic, putFirmware(payload))
        elif command == "getLogs":
            publish_response(client, response_topic, getLogs(payload))
        elif command == "setConfigTbGateway":
            publish_response(client, response_topic, setConfigTbGateway(payload))
        elif command == "reset":
            result = reset(payload)
            if(result == {"success": "true"}):
                publish_response(client, response_topic, result)
                #os.system("sudo reboot")
            else:
                publish_response(client, response_topic, result)    
        elif command == "reboot":
            publish_response(client, response_topic, reboot(payload))
        elif command == "getInfos":
            publish_response(client, response_topic, getInfos(payload))            

    # Handle device-specific topics
    match = re.match(r"device/([^/]+)/request/(\w+)/(\d+)", topic)
    if match:
        device_name, command, request_id = match.groups()
        response_topic = f"device/{device_name}/response/{command}/{request_id}"

        if command == "setDevice":
            publish_response(client, response_topic, setDevice(payload))
        elif command == "getDeviceInfos":
            publish_response(client, response_topic, getInfos(payload))

