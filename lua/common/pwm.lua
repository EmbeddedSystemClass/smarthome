print("PWM Function test")

local pin = 8

gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)
pwm.setup(pin,1000,1023);
pwm.start(pin);

local r=512;
local flag=1;

local min=0;
local max=1023;
local step=50;

--pwm.setduty(6, 512)

tmr.alarm(2,100,1,function()
     pwm.setduty(pin,r);
     if flag==1 then
     r=r-step; if r <= min then flag=0 r=min end
     else
     r= r+step; if r>=max then flag=1 r=max end
end
end)
