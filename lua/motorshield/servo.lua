local servo = {}

local pins = {5, 6, 7, 8}
local clock = 100

local min=60;
local max=240;

print("Init servos: ")
for i = 1, table.getn(pins) do
    print("pin: " .. pins[i]) 
    gpio.mode(pins[i], gpio.OUTPUT)
    gpio.write(pins[i], gpio.LOW)
    pwm.setup(pins[i],clock,min);
    pwm.start(pins[i])
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