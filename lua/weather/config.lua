-- GPIOS
GPIO_LED = 4
GPIO_DHT = 6
GPIO_ONEWIRE = 7

-- WiFi networks list in format [SSID] = password
WIFI_AUTH = {
["Wlan_WP2"] = "Chronion.7",
["Sagem4.3"] = "sagem_5ru"
}

-- Alarms
WIFI_ALARM_ID = 0
WIFI_LED_BLINK_ALARM_ID = 1
PUBLISH_ALARM_ID = 2
TEMPER_ALARM_ID = 3
DHT_ALARM_ID = 4

-- MQTT
MQTT_CLIENTID = "terrace"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883
MQTT_MAINTOPIC = "/" .. MQTT_CLIENTID
MQTT_USERNAME = ""
MQTT_PASSWORD = ""

-- OTHERS
TELNET_MODULE = 1 -- 1 to active


-- Confirmation message
print("\nGlobal variables loaded...\n")
