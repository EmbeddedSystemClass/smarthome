local pin = 2    --> GPIO4

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
    print('The pin value has changed to '..gpio.read(pin))
end

gpio.mode(pin, gpio.INT, gpio.PULLUP)
gpio.trig(pin, 'down',  debounce(onChange))