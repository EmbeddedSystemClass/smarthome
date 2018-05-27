local servo = {}

local pins = {5, 6, 7, 8}
local clock = 60

local min=65;
local max=150;

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
