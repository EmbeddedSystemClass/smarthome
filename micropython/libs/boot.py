
import config, led, network, time

def do_connect(ssid, password):
    tm = 0
    sta_if = network.WLAN(network.STA_IF)
    if not sta_if.isconnected():
        print('Connecting to %s...' % ssid)
        sta_if.active(True)
        sta_if.connect(ssid, password)
        while not sta_if.isconnected():
            time.sleep(0.01)
            tm+=1
            if (tm > 100 * 6):
                #6 sec timeout
                print('Timeout')
                return False
    print('Connected (%s)' % sta_if.ifconfig()[0])
    return True

def connect_wlan():
    SysLed = led.SysLed()
    SysLed.RunFlicker(500)
    for ssid, passwd in config.ssids:
        if do_connect(ssid, passwd):
            SysLed.StopFlicker()
            del(SysLed)
            return True
    SysLed.RunFlicker(200)
    return False