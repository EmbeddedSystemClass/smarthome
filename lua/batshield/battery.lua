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
local min_voltage = 3.6
local max_voltage = 4.2

-- Limited to local environment
setfenv(1,M)


adc.force_init_mode(adc.INIT_ADC)


function get_raw()
    return adc.read(0)
end

function get_volt()
    return max_voltage * get_raw() / 1023
end

function get_level()
    return (get_volt() - min_voltage) / (max_voltage - min_voltage) * 100
end

return M