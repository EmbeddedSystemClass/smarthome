print("PWM Function test")

local r = 8
local g = 7
local b = 6
local pin = r

gpio.mode(r, gpio.OUTPUT)
gpio.mode(g, gpio.OUTPUT)
gpio.mode(b, gpio.OUTPUT)
gpio.write(r, gpio.LOW)
gpio.write(g, gpio.LOW)
gpio.write(b, gpio.LOW)

pwm.setup(r,1000,1023);
pwm.setup(g,1000,1023);
pwm.setup(b,1000,1023);
pwm.start(r);
pwm.start(g);
pwm.start(b);

local d=512;
local flag=0;

local min=0;
local max=1023;
local step=50;

--pwm.setduty(6, 512)

tmr.alarm(2,100,1,function()
     pwm.setduty(pin,1023-d)
     print(pin)
     if flag==1 then
     d=d-step; if d <= min then flag=0 d=min end
     else
        d=d+step
        if d>=max then 
            flag=1 
            d=max 
            if pin==b then pin=r
            elseif pin==g then pin=b 
            else pin=g 
            end
        end
end
end)
