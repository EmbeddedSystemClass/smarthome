-- Config
local pin = 4            --> GPIO2
local value = gpio.LOW
local duration = 100    --> 1 second
local count = 5
local n = 0

-- Function toggles LED state
function toggleLED ()
    if value == gpio.LOW then
        value = gpio.HIGH
        n = n + 1
    else
        value = gpio.LOW
        
    end

    gpio.write(pin, value)

    if n == count then
        tmr.stop(0)
--        node.dsleep(0)
    end 
end


-- Initialise the pin
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, value)

-- Create an interval
tmr.alarm(0, duration, 1, toggleLED)