from umqtt.robust import MQTTClient
import time, machine, ubinascii

class Client:
    def __init__(self, client_id, broker, port = 1883, user=None, password=None):
        self.id = client_id
        self.client=MQTTClient(self.id, broker, port, user, password)

    def connect(self):
       self.client.connect()

    def is_connected(self):
        return self.client.is_connected()

    def servicepub(self, ip):
        uptime = time.time()
        dd = int(uptime / (3600 * 24))
        hh = int((uptime / 3600) % 24)
        mm = int((uptime / 60) % 60)
        buf = str(dd) + 'd ' + str(hh) + 'h ' + str(mm) + 'm'
        self.client.publish('/' + self.id + '/uptime', buf)
        self.client.publish('/' + self.id + '/ip', ip)

    def publish(self, topic, msg):
        self.client.publish(topic, msg)



