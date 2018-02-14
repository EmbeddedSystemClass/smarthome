#!/usr/bin/python

import sys, bluetooth, time, os
import paho.mqtt.client as mqtt

MQTT_SERVER = "192.168.1.206"
MQTT_PORT = 1883
MQTT_CLIENT_ID = "bluediscover"

targets = {"78:02:F8:03:68:30":"/presence/mibt",
           "4C:49:E3:24:6A:8A":"/presence/mi5cbt"}


client = mqtt.Client(MQTT_CLIENT_ID)
connected = False

def on_connect(client, userdata, rc):
    client.subscribe("/f", 0)
    print "Connected."
    global connected
    connected = True

def on_message(mosq, obj, msg):
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))

def connect_broker():
    print "Connecting to broker %s..." %(MQTT_SERVER),
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
    devices = bluetooth.discover_devices(lookup_names=True)
    print "Found %d devices" % len(devices)
    
    for addr, name in devices:
        print "  %s - %s" % (addr, name)
        
    return devices


def monitor():
    while True:
        print "\r\nScanning.."
        nearby_devices = scan()
        
        for addr in targets:
            msg = "0"
            for faddr, fname in nearby_devices:
                if faddr == addr:
                    msg = "1"
                    break
                else:
                    continue
            print "Publish: %s - %s" %(targets[addr], msg)
            client.publish(targets[addr], msg)

        time.sleep(10)
                

def main():
    try:
        connect_broker()
        while not connected:
            time.sleep(0.5)
        monitor()
    except (KeyboardInterrupt, SystemExit):
        print "\r\nExit"


if  __name__ ==  "__main__" : main()
