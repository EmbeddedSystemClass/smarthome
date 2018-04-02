import umqtt.robust
import time, machine, ubinascii

class MQTTClient(umqtt.robust.MQTTClient):
    def __init__(self, client_id, broker, port = 1883, user = None, password = None):
        self.connected = False
        self.tmr = None
        umqtt.robust.MQTTClient.__init__(self, client_id, broker, port, user, password)

    def _reconnect_cb(self, timer = None):
        self.reconnect()

    def reconnect(self):
        try:
            print("reconnecting")
            res = super(umqtt.robust.MQTTClient, self).connect(False)
            self.connected = True
            if self.tmr != None:
                self.tmr.deinit()
            return res
        except OSError as e:
            self.log(True, e)
            if self.tmr == None:
                self.tmr = machine.Timer(-1)
            self.tmr.init(period = int(1000), mode = machine.Timer.ONE_SHOT, callback = self._reconnect_cb)

    def publish(self, topic, msg, retain=False, qos=0):
        try:
            return super(umqtt.robust.MQTTClient, self).publish(topic, msg, retain, qos)
        except OSError as e:
            self.log(False, e)
        self.connected = False
        self.reconnect()

class Client:
    def __init__(self, client_id, broker, port = 1883, user = None, password = None):
        self.id = client_id
        self.broker = broker
        self.client = MQTTClient(self.id, broker, port, user, password)

    def connect(self):
        try:
            clean_session = self.client.connect(clean_session = False)
        except:
            print("Fail to connect to " + self.broker)
        else:
            print("Connected to " + self.broker)
            if clean_session:
                print("Set up a new session")

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



