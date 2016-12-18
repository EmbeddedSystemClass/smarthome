local left_button = 0
local right_button = 1
local fd_button = 2
local rr_button = 3

local pins = {1, 2, 3, 6}


function debounce (func)
    local last = 0
    local delay = 500000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function onChange ()
    print('The pin value has changed')
end

print("Init Inputs: ")
for i = 1, table.getn(pins) do
    print("pin: " .. pins[i]) 
    gpio.mode(pins[i], gpio.INT, gpio.PULLUP)
    gpio.trig(pins[i], 'down',  debounce(onChange))
end

adc.force_init_mode(adc.INIT_ADC)

tmr.alarm(5, 500, 1, function ()
    val = adc.read(0)
    if val > pos+5 or val < pos-5 then
        print (val)
        pos = val
    end
 end)
