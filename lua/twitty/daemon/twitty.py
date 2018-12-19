#!/usr/bin/python
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
import paho.mqtt.client as mqtt
from urlparse import urlparse, parse_qs
import json

PORT_NUMBER = 8080
MQTT_SERVER = "127.0.0.1"
MQTT_PORT = 1883
VERBOSE = 1

def on_connect(client, userdata, rc):
    print("Connected with result code " + str(rc))

def on_message(client, userdata, message):
    print("message:", str(message.payload.decode("utf-8")))
    print("topic:", message.topic)

class myHandler(BaseHTTPRequestHandler):
    def print_request(self, payload):
        print("\n----- Request from %s ----->\n" % self.address_string())
        print(self.path)
        print(self.headers)
        if payload:
            print(payload)
        print("<----- Request End -----\n")

    def do_GET(self):
        self.send_response(200)
        self.end_headers()

        query_components = parse_qs(urlparse(self.path).query)

        content_length = self.headers.getheaders('content-length')
        length = int(content_length[0]) if content_length else 0
        
        tweet = {}
        payload = None
        if length:
            payload = self.rfile.read(length)
            if payload:
                tweet = json.loads(payload)
        
        if VERBOSE:
            self.print_request(payload)

        try:
            topic = '/' + ''.join(query_components["topic"])
            text = tweet["text"]
            user = tweet["username"]
            msg = user + ':' + text
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
        self.send_response(200)
        self.end_headers()

        query_components = parse_qs(urlparse(self.path).query)
        
        content_length = self.headers.getheaders('content-length')
        length = int(content_length[0]) if content_length else 0
        
        tweet = {}
        payload = None
        if length:
            payload = self.rfile.read(length)
            print payload
            if payload:
                try:
                    tweet = json.loads(payload)
                except ValueError:
                    print "Wrong payload: " + payload
                    return

        
        if VERBOSE:
            self.print_request(payload)

        try:
            topic = '/' + ''.join(query_components["topic"])
            text = tweet["text"]
            user = tweet["username"]
            msg = user + ':' + text
        except KeyError:
            print "Wrong request"
            #self.wfile.write("ERROR")
            return
            
        print "Topic:", topic
        print "Message:", msg.encode("utf-8")

        client.publish(topic, msg)
        self.wfile.write("OK")
        return


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(MQTT_SERVER, MQTT_PORT, 60)
client.loop_start()
#client.subscribe("/stats", qos=0)


try:
    server = HTTPServer(('', PORT_NUMBER), myHandler)
    print 'Started httpserver on port', PORT_NUMBER
    server.serve_forever()

except KeyboardInterrupt:
    print '^C received, shutting down the web server'
    server.socket.close()
    client.loop_stop()