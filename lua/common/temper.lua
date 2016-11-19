t = require("ds18b20")

-- ESP-01 GPIO Mapping
gpio5 = 1

t.setup(gpio5)
addrs = t.addrs()
if (addrs ~= nil) then
  n_sensor = table.getn(addrs)
  print("Total DS18B20 sensors: "..n_sensor)
end

if (n_sensor ~= 0) then
    temp = t.read() 
    tmr.alarm(3, 5000, 1, function ()
    temp = t.read() 
    if (temp ~= nil ) then
        print("Temperature: "..temp.."'C")
    end
end)
end

-- Just read temperature
--print("Temperature: "..t.read().."'C")

-- Get temperature of first detected sensor in Fahrenheit
--print("Temperature: "..t.read(nil,t.F).."'F")

-- Query the second detected sensor, get temperature in Kelvin
--if (table.getn(addrs) >= 2) then
--   print("Second sensor: "..t.read(addrs[2],t.K).."'K")
--end

-- Don't forget to release it after use
--t = nil
--ds18b20 = nil
--package.loaded["ds18b20"]=nil
