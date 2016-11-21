print("Servo test")

local pin = 9
local clock = 100
local flag=1;
local min=55;
local max=240;

gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)
pwm.setup(pin,clock,min);
pwm.start(pin)

tmr.alarm(2,2000,1,function()
     if flag==1 then
        pwm.setduty(pin,min)
        flag=0 
     else
        pwm.setduty(pin,max)
        flag=1 
end  
end)
