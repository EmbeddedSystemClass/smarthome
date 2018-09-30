local modname = ...
local M = {}
if modname == nil then
    modname = "mq135"
end
_G[modname] = M

local adc = adc
local moving_average = require "filter"

setfenv(1,M)

-- The load resistance on the board
local RLOAD = 1.0
-- Calibration resistance at atmospheric CO2 level
local RZERO = 40.80
--- Atmospheric CO2 level for calibration purposes
local ATMOCO2 = 397.13

-- Parameters for calculating ppm of CO2 from sensor resistance
local PARA = 116.6020682
local PARB = 2.769034857

adc.force_init_mode(adc.INIT_ADC)

local filter = moving_average(10)

function get_raw()
    return adc.read(0)
end

function get_volt()
    return get_raw() / 1023
end

function get_resist()
    return ((1023 / get_raw()) * 5 - 1) * RLOAD
end

function get_ppm()
    return PARA * ((get_resist()/RZERO) ^ (-PARB))
end

function get_fppm()
    return filter:get_value(get_ppm())
end

function get_rzero()
    return get_resist() * ((ATMOCO2 / PARA) ^ (1./PARB))
end


return M
