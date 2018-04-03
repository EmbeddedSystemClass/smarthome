import umqtt.robust
import time, machine, ubinascii

class MQTTClient(umqtt.robust.MQTTClient):
    RECONNECT_TIMEOUT = 5000
    KEEPALIVE_PERIOD = 60
    def __init__(self, client_id, broker, port = 1883, user = None, password = None, keepalive = KEEPALIVE_PERIOD):
        self.id = client_id
        self.broker = broker
        self.connected = False
        self.tmr = None
        umqtt.robust.MQTTClient.__init__(self, client_id, broker, port, user, password, self.KEEPALIVE_PERIOD)

    def is_connected(self):
        return self.connected

    def _reconnect_cb(self, timer = None):
        self.reconnect()

    def reconnect(self):
        try:
            print("Reconnecting to " + self.broker)
            res = super(umqtt.robust.MQTTClient, self).connect(False)
            self.connected = True
            print("Connected to " + self.broker)
            if self.tmr != None:
                self.tmr.deinit()
            return res
        except OSError as e:
            self.log(True, e)
            self.connected = False
            if self.tmr == None:
                self.tmr = machine.Timer(-1)
            self.tmr.init(period = int(self.RECONNECT_TIMEOUT), mode = machine.Timer.ONE_SHOT, callback = self._reconnect_cb)

    def publish(self, topic, msg, retain=False, qos=0):
        try:
            return super(umqtt.robust.MQTTClient, self).publish(topic, msg, retain, qos)
        except OSError as e:
            self.log(False, e)
        self.reconnect()


class Client(MQTTClient):
    def connect(self):
        self.set_last_will("/lwt/"+self.client_id, "died")
        try:
            clean_session = super(MQTTClient, self).connect(clean_session = False)
        except OSError as e:
            self.log(False, e)
            print("Fail to connect to " + self.broker)
        else:
            print("Connected to " + self.broker)
            if clean_session:
                print("New session")
                #Put here subscribe routines

    def servicepub(self, ip):
        uptime = time.time()
        dd = int(uptime / (3600 * 24))
        hh = int((uptime / 3600) % 24)
        mm = int((uptime / 60) % 60)
        buf = str(dd) + 'd ' + str(hh) + 'h ' + str(mm) + 'm'
        self.publish('/' + self.id + '/uptime', buf)
        self.publish('/' + self.id + '/ip', ip)

