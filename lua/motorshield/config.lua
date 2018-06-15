-- GPIOS
GPIO_LED = GPIO2
GPIO_SWITCH = GPIO5
GPIO_BUTTON = GPIO0

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
MQTT_CLIENTID = "motor"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883
MQTT_MAINTOPIC = "/" .. MQTT_CLIENTID
MQTT_USERNAME = ""
MQTT_PASSWORD = ""

-- OTHERS
BUTTON_DEBOUNCE = 500000
TELNET_MODULE = 0
HTTP_MODULE = 0


-- Confirmation message
print("\nGlobal variables loaded...\n")
