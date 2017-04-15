#!/usr/bin/python

import paho.mqtt.client as mqtt

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, rc):
	print("Connected with result code "+str(rc))
	# Subscribing in on_connect() means that if we lose the connection and
	# reconnect then subscriptions will be renewed.
	client.subscribe("/motor/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
	print(msg.topic+" "+str(msg.payload)+"\r\n")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("192.168.1.206", 1883, 60)

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
#client.loop_forever()
client.loop_start()

import curses
stdscr = curses.initscr()
curses.cbreak()
stdscr.keypad(1)

stdscr.addstr(0,0,"Hit 'q' to quit\r\n")
stdscr.refresh()

key = ''
while key != ord('q'):
    key = stdscr.getch()
    if key == curses.KEY_UP: 
	client.publish("/motor/cmd/forward", 1023)
    elif key == curses.KEY_DOWN: 
	client.publish("/motor/cmd/forward", 0)
    elif key == curses.KEY_LEFT: 
	client.publish("/motor/cmd/left", 1023)
    elif key == curses.KEY_RIGHT: 
	client.publish("/motor/cmd/right", 1023)

curses.endwin()
