print("PWM Function test")

local pin = 7

gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)
pwm.start(pin);

local flag=1;

local min=55;
local max=240;

pwm.setup(pin,100,max);

tmr.alarm(2,2000,1,function()
     if flag==1 then
        pwm.setduty(pin,min)
        flag=0 
     else
        pwm.setduty(pin,max)
        flag=1 
end  
end)
