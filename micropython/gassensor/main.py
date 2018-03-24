import sys
import wifi
import led
import mqtt
import machine
import ujson
import ubinascii
import network

MQTT_SYSPUB_PERIOD = 1000 * 60 * 5

clients = []

#Load config file
def load_config():
    try:
        with open('config.json') as config_file:
            conf = ujson.load(config_file)
    except (OSError, ValueError):
        return None
    return conf

#Callback to publish service data
def servicepub_cb(timer):
    ip = wlan.getip()
    for client in clients:
        client.servicepub(ip)
        sysled.Flick()

#Init blue LED
sysled = led.SysLed()

#Load configuration
config = load_config()
if not config:
    print("Couldn't load /config.json")
    sysled.RunFlicker(200)
    sys.exit()

#Connect to WIFI
wlan = wifi.Wlan(config['wlan'])
wlan.connect()

#Form unique client ID with a MAC part
client_id = config['mqtt']['client_id'] + '-' \
    + ubinascii.hexlify(network.WLAN().config('mac')).decode()[-6:]

#Connect to brokers
for broker in config['mqtt']['brokers']:
    client = mqtt.Client(client_id, broker['ip'], int(broker['port']), 
        broker['user'], broker['passwd'])
    client.connect()
    client.servicepub(wlan.getip())
    clients.append(client)
    sysled.Flick()

#Init service data publish timer
t = machine.Timer(-1)
t.init(period = int(MQTT_SYSPUB_PERIOD), mode = machine.Timer.PERIODIC, callback = servicepub_cb)
