
import config

def do_connect(ssid, password):
    import network
    import time
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
    for ssid, passwd in config.ssids:
        if do_connect(ssid, passwd):
            return True
    return False