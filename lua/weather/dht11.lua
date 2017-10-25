local REQUEST_PERIOD = 10000
local status, temp, humi, temp_dec, humi_dec

tmr.alarm(DHT_ALARM_ID, REQUEST_PERIOD, 1, function ()

    status, temp, humi, temp_dec, humi_dec = dht.read(GPIO_DHT)

    if status == dht.OK then
        print("DHT: "..temp.."'C "..humi.."%")
        dhttemp = temp
        dhthumi = humi
    elseif status == dht.ERROR_CHECKSUM then
        dhttemp = "break"
        dhthumi = "break"
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        dhttemp = "break"
        dhthumi = "break"
        print( "DHT timed out." )
    end
end)
