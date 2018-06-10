t = require("ds18b20_lua")

temperature = {}
local REQUEST_PERIOD = 10000
local MAX_ATTEMPTS = 3
local index = 1

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


function request_sensors_onebyone()
  for num, addr in pairs(addrs) do 
    if (num == index) then
        if (index < n_sensor) then 
            index = index + 1
        else 
            index = 1
        end
        local temp = t.read(addr)
        if (temp ~= nil ) then
            temperature[get_sensor_id(addr)] = temp
            print("Sensor "..get_sensor_id(addr)..": "..temp.."'C")
        else
            temperature[get_sensor_id(addr)] = 85.0
            print("Sensor "..get_sensor_id(addr)..": break")
        end
        break
    end
  end
end

function request_sensors()
  for num, addr in pairs(addrs) do
    local count = 0
    local temp
    repeat
        temp = t.read(addr)
        count = count + 1
    until ((temp ~= nil ) or (count >= MAX_ATTEMPTS))
    if (temp ~= nil ) then
        temperature[get_sensor_id(addr)] = temp
        print("Sensor "..get_sensor_id(addr)..": "..temp.."'C")
    else
        temperature[get_sensor_id(addr)] = 85.0
        print("Sensor "..get_sensor_id(addr)..": line break")
    end 
  end
end

if (n_sensor ~= 0) then
    tmr.alarm(TEMPER_ALARM_ID, REQUEST_PERIOD, 1, request_sensors)
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
