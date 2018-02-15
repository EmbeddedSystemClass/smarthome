-- GPIOS
GPIO_LED = 4
GPIO_SWITCH = 5
GPIO_BUTTON = 3

-- WiFi networks list in format [SSID] = password
WIFI_AUTH = {
["Sagem4.3"] = "sagem_5ru",
["Wlan_WP2"] = "Chronion.7"
}

-- Alarms
WIFI_ALARM_ID = 0
WIFI_LED_BLINK_ALARM_ID = 1
PUBLISH_ALARM_ID = 2

-- MQTT
MQTT_CLIENTID = "socket-"..node.chipid()
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883
MQTT_MAINTOPIC = "/" .. MQTT_CLIENTID
MQTT_USERNAME = ""
MQTT_PASSWORD = ""

-- OTHERS
BUTTON_DEBOUNCE = 500000
TELNET_MODULE = 1 -- 1 to active


-- Confirmation message
print("\nGlobal variables loaded...\n")
