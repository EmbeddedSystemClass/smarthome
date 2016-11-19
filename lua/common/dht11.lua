pin = 5

local status, temp, humi, temp_dec, humi_dec

tmr.alarm(4, 5000, 1, function ()

    status, temp, humi, temp_dec, humi_dec = dht.read(pin)

    if status == dht.OK then
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        dhttemp = temp
        dhthumi = humi
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end

end)
