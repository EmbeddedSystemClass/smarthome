local FLOOD_TRESHOLD = 400

-- Init ADC
adc.force_init_mode(adc.INIT_ADC)


function GetWaterLevel()
    val = adc.read(0)
    print("Water:", val)
    return val
end


function IsFlood()
    val = GetWaterLevel()
    if val >= FLOOD_TRESHOLD then
        res = true
    else
        res = false
    end
    print("Flood:", res)
    return res
end

