import machine, math, time

class Led:
    def __init__(self, gpio, inverted = False):
        self.tmr = None
        self.gpio = gpio
        self.inverted = inverted
        self.pin = machine.Pin(self.gpio, machine.Pin.OUT, value = self.inverted)

    def On(self):
        self.pin.value(not self.inverted)

    def Off(self):
        self.pin.value(self.inverted)

>>>
    def Toggle(self):
        self.pin.value(not self.pin.value())

    def Flick(self, ms = 50):
        self.On()
        timer = machine.Timer(-1)
        timer.init(period = int(ms), mode = machine.Timer.ONE_SHOT, callback = self.__OffCallback)

    def __OffCallback(self, timer = None):
        self.Off()
        timer.deinit()
        del(timer)

    def __FlickTmrCallback(self, timer = None):
        self.Flick()

    def RunFlicker(self, ms):
        if self.tmr == None:
            self.tmr = machine.Timer(-1)
        self.tmr.init(period = int(ms), mode = machine.Timer.PERIODIC, callback = self.__FlickTmrCallback)

    def StopFlicker(self):
        self.tmr.deinit()
        self.Off()
        del(self.tmr)

    # def FadeFlick(self, ms = 50):
    #     self.fled = machine.PWM(self.pin, freq = 1000)
    #     self.fled.duty(0)
    #     for i in range(ms):
    #          self.fled.duty(self.fled.duty() + int(1023 / ms))
    #          time.sleep_ms(1)
    #     self.fled.duty(1023)
        

class SysLed(Led):
    def __init__(self):
        Led.__init__(self, 2, True)
