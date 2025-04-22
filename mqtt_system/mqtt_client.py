import paho.mqtt.client as mqtt
import config
from command_handler import handle_command

class MQTTClient:
    def __init__(self):
        self.client = mqtt.Client()
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

    def on_connect(self, client, userdata, flags, rc):
        print("Connected to MQTT Broker!")
        client.subscribe(config.BASE_REQUEST_TOPIC + "#")  # Subscribe to all request topics
        client.subscribe(config.DEVICE_REQUEST_TOPIC.format(deviceName="+") + "#")  # Subscribe to device requests

    def on_message(self, client, userdata, msg):
        print(f"Received message on {msg.topic}")
        handle_command(self.client, msg.topic, msg.payload.decode())

    def start(self):
        self.client.connect(config.MQTT_BROKER, config.MQTT_PORT, 60)
        self.client.loop_forever()

