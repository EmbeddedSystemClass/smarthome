#!/usr/bin/python
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
import paho.mqtt.client as mqtt
from urlparse import urlparse, parse_qs

PORT_NUMBER = 8080
MQTT_SERVER = "localhost"
MQTT_PORT = 1883
VERBOSE = 1

def on_connect(client, userdata, rc):
    print("Connected with result code "+str(rc))

class myHandler(BaseHTTPRequestHandler):
    def print_request(self)
        print("\n----- Request from %s ----->\n" % self.address_string())
        print(self.path)
        request_headers = self.headers
        content_length = request_headers.getheaders('content-length')
        length = int(content_length[0]) if content_length else 0
        print(request_headers)
        print(self.rfile.read(length))
        print("<----- Request End -----\n")

    def do_GET(self):
        if VERBOSE:
            print_request(self)

        self.send_response(200)
        self.end_headers()

        query_components = parse_qs(urlparse(self.path).query)
        print("Querry:", query_components)

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

    def do_POST(self):
        if VERBOSE:
            print_request(self)

        self.send_response(200)
        self.end_headers()
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