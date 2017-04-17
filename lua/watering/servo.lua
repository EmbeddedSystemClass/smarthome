local servo = {}

pins = {1, 4, 3, 5, 6}
local clock = 100

local min=150;
local max=240;

print("Init servos: ")
for i, p in pairs(pins) do
    print("pin: " .. pins[i]) 
    gpio.mode(p, gpio.OUTPUT)
    gpio.write(p, gpio.LOW)
    pwm.setup(p,clock,min);
    pwm.start(p)
end

function servo.set(pin,pos)
    if (pos < min) then 
        pos = min
    else if (pos > max) then
        pos = max
    end
    end
    pwm.setduty(pin,pos)
    print(pin .. " -> " .. pos)
end

return servo
