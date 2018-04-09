-- Set module name as parameter of require
local modname = ...
local M = {}
if modname == nil then
    modname = "battery"
end
_G[modname] = M

local adc = adc
local tmr = tmr
local voltage = 0
local level = 0

-- Limited to local environment
setfenv(1,M)


adc.force_init_mode(adc.INIT_ADC)

--tmr.alarm(5, 500, 1, function ()
--    local raw = adc.read(0)
--    --print(raw)
--    voltage = 4.2 * raw / 1023
--    level = voltage / 4.2 * 100
--end)

function get_raw()
    return adc.read(0)
end

function get_volt()
    return 4.2 * adc.read(0) / 1023
end

function get_level()
    return get_volt() / 4.2 * 100
end

return M