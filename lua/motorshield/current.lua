local ina = require "ina3221"

if not ina.init() then 
    print("ina3221 init error")
end

print("Manufacturer ID: " .. string.format("0x%X", ina.get_manid()))

for i = 1, 3 do
    print("Channel: " .. i) 
    print("U: " .. ina.get_voltage_V(i) .. "V")
    print("I: " .. ina.get_current_mA(i) .. "mA")
end
