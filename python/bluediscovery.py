#!/usr/bin/python

import sys, bluetooth, time
import paho.mqtt.client as mqtt

MQTT_SERVER = "192.168.1.206"
MQTT_PORT = 1883
MQTT_CLIENT_ID = "bluediscover"

targets = {"78:02:F8:03:68:30":"/presence/mibt"}

client = mqtt.Client(MQTT_CLIENT_ID)


def on_connect(client, userdata, rc):
    client.subscribe("/f", 0)
    print "Connected"

def on_message(mosq, obj, msg):
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))

def connect_broker():
    print "Connecting to broker %s..." %(MQTT_SERVER)
    try:
        rc = client.connect(MQTT_SERVER, MQTT_PORT, 60)
    except Exception as detail:
        print "Broker connection error:", detail
        sys.exit()
    if rc == 0:
        client.on_connect = on_connect
        client.on_message = on_message
        client.loop_start()
    else:
        print "Broker error (%s). Exit." %(rc)
        sys.exit()


def scan():
    nearby_devices = bluetooth.discover_devices(lookup_names=True)
    print "Found %d devices" % len(nearby_devices)
    
    for addr, name in nearby_devices:
        print "  %s - %s" % (addr, name)
        
    return nearby_devices


def monitor():
    while True:
        print "Scanning.."
        nearby_devices = scan()
        
        for addr in targets:
            msg = "0"
            for faddr, fname in nearby_devices:
                if faddr == addr:
                    msg = "1"
                    break
                else:
                    continue
            print "%s - %s" %(targets[addr], msg)
            client.publish(targets[addr], msg)
                  
            
#         for addr, name in nearby_devices:
#             if targets.get(addr):
#                 msg = "1"
#             else:
#                 msg = "0"
#                 
#             print "%s - %s" %(targets[addr], msg)
#             client.publish(targets[addr], msg)
                
        time.sleep(10)
                

def main():
    connect_broker()
    monitor()


if  __name__ ==  "__main__" : main()
