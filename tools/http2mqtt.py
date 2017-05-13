#!/usr/bin/python
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
import paho.mqtt.client as mqtt
from urlparse import urlparse, parse_qs

PORT_NUMBER = 1234
MQTT_SERVER = "192.168.1.206"
MQTT_PORT = 1883

def on_connect(client, userdata, rc):
        print("Connected with result code "+str(rc))

class myHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		self.send_response(200)
		self.end_headers()
		query_components = parse_qs(urlparse(self.path).query)
		try:
			msg = ''.join(query_components["message"])
			topic = '/' + ''.join(query_components["topic"])
		except KeyError:
			print "Wrong request"
			self.wfile.write("ERROR")
			return
		print "Topic:", topic
		print "Message:", msg
		client.publish(topic, msg)
		self.wfile.write("OK")
		return


client = mqtt.Client()
client.on_connect = on_connect

client.connect(MQTT_SERVER, MQTT_PORT, 60)

try:
	server = HTTPServer(('', PORT_NUMBER), myHandler)
	print 'Started httpserver on port ' , PORT_NUMBER
	server.serve_forever()

except KeyboardInterrupt:
	print '^C received, shutting down the web server'
	server.socket.close()
