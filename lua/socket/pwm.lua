print("PWM Function test")
--gpio.mode(4, gpio.OUTPUT)
--gpio.write(4, gpio.HIGH)
--gpio.write(4, gpio.LOW)
pwm.setup(4,1000,1023);
pwm.start(4);

local r=512;
local flag=1;

--pwm.setduty(4, 1000)

tmr.alarm(2,100,1,function()
     pwm.setduty(4,r);
     if flag==1 then
     r=r-50; if r < 0 then flag=0 r=0 end
     else
     r= r+50; if r>1023 then flag=1 r=1023 end
end
end)