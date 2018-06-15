import adc

class Sensor(adc.ADC):
    def __init__(self):
        adc.ADC.__init__(self)

    def get_co(self):
        return None


