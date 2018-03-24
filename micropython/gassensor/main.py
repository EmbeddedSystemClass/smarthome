from wlan import *
import led
import mqtt
import machine
import ujson
import ubinascii
import network
import sys

MQTT_SYSPUB_PERIOD = 1000 * 60 * 5

#Load config file
def load_config():
    try:
        with open('config.json') as config_file:
            config = ujson.load(config_file)
    except (OSError, ValueError):
        return None
    return config

#Callback to publish service data
def servicepub_cb(timer):
    ip = wlan.getip()
    m.servicepub(ip)
    c.servicepub(ip)
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
wlan = Wlan(config['wlan'])
wlan.connect()

#Form unique client ID with a MAC part
client_id = config['mqtt']['client_id'] + '-' \
    + ubinascii.hexlify(network.WLAN().config('mac')).decode()[-6:]

#Connect to local broker
m = mqtt.Client(client_id, config['mqtt']['brokers'][0]['ip'], 
    int(config['mqtt']['brokers'][0]['port']), 
    config['mqtt']['brokers'][0]['user'], 
    config['mqtt']['brokers'][0]['passwd'])
m.connect()
m.servicepub(wlan.getip())
sysled.Flick()

#Connect to remote broker
c = mqtt.Client(client_id, config['mqtt']['brokers'][1]['ip'], 
    int(config['mqtt']['brokers'][1]['port']), 
    config['mqtt']['brokers'][1]['user'], 
    config['mqtt']['brokers'][1]['passwd'])
c.connect()
c.servicepub(wlan.getip())
sysled.Flick()

#Init service data publish timer
t = machine.Timer(-1)
t.init(period = int(MQTT_SYSPUB_PERIOD), mode = machine.Timer.PERIODIC, callback = servicepub_cb)
