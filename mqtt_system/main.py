from mqtt_client import MQTTClient

if __name__ == "__main__":
    print("Starting MQTT Command System...")
    mqtt_client = MQTTClient()
    mqtt_client.start()

