import config, led, network, time

class Wlan():
    def __init__(self):
        self.sta_if = None

    def getip(self):
        return self.sta_if.ifconfig()[0]

    def do_connect(self, ssid, password):
        tm = 0
        self.sta_if = network.WLAN(network.STA_IF)
        if not self.sta_if.isconnected():
            print('Connecting to %s...' % ssid)
            self.sta_if.active(True)
            self.sta_if.connect(ssid, password)
            while not self.sta_if.isconnected():
                time.sleep(0.01)
                tm+=1
                if (tm > 100 * 6):
                    #6 sec timeout
                    print('Timeout')
                    return False
        print('Connected (%s)' % self.sta_if.ifconfig()[0])
        return True


    def connect(self):
        SysLed = led.SysLed()
        SysLed.RunFlicker(500)
        for ssid, passwd in config.ssids:
            if self.do_connect(ssid, passwd):
                SysLed.StopFlicker()
                del(SysLed)
                return True
        SysLed.RunFlicker(200)
        return False