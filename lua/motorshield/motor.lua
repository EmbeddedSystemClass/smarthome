local motor = {}

local pwma = 1
local pwmb = 2
local da = 3
local db = 4

local clock = 100

local pins = {pwma, pwmb, da, db}

for i = 1, table.getn(pins) do
    gpio.mode(pins[i], gpio.OUTPUT)
    gpio.write(pins[i], gpio.LOW)
end

pwm.setup(pwma,clock,0);
pwm.start(pwma)
pwm.setup(pwmb,clock,0);
pwm.start(pwmb)

function motor.set(ch, dir, speed)
    if (ch == "A") then
        print("A: " .. dir .. " " .. speed)
        if (dir == "F") then
            gpio.write(da, gpio.LOW)
        else if (dir == "R") then 
             gpio.write(da, gpio.HIGH)
        end
        end
        pwm.setduty(pwma,speed);
    else if (ch == 'B') then
        print("B: " .. dir .. " " .. speed)
        if (dir == "F") then
            gpio.write(db, gpio.LOW)
        else if (dir == "R") then 
             gpio.write(db, gpio.HIGH)
        end
        end
        pwm.setduty(pwmb,speed);
    end
    end
end


   
return motor
