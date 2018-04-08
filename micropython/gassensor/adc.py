import machine

class ADC():
    def __init__(self):
        self.adc = machine.ADC(0)

    def get_raw(self):
        return self.adc.read()

    def get_volt(self):
        return self.get_raw() / 1023