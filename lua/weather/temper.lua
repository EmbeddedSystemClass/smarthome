t = require("ds18b20")

temperature = {}
local REQUEST_PERIOD = 10000

t.setup(GPIO_ONEWIRE)
addrs = t.addrs()


function get_sensor_id(addr)
    return ('%02X%02X%02X'):format(addr:byte(6,8))
end

if (addrs ~= nil) then
  n_sensor = table.getn(addrs)
  print("Total DS18B20 sensors: "..n_sensor)
  for key,value in pairs(addrs) do 
    print(key..".", get_sensor_id(value)) 
  end
end


function request_sensors()
  for num, addr in pairs(addrs) do 
    local temp = t.read(value)
    if (temp ~= nil ) then
        temperature[get_sensor_id(addr)] = temp
        print("Sensor "..get_sensor_id(addr)..": "..temp.."'C")
    else
        temperature[get_sensor_id(addr)] = 85.0
        print("Sensor "..get_sensor_id(addr)..": error")
    end
  end
end


if (n_sensor ~= 0) then
    tmr.alarm(TEMPER_ALARM_ID, 5000, 1, request_sensors)
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
