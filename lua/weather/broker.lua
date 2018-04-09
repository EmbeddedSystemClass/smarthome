local dispatcher = {}

local PUBLISH_PERIOD = 10000
local SERVICE_PERIOD = PUBLISH_PERIOD * 6
local service_cnt = SERVICE_PERIOD / PUBLISH_PERIOD

-- client activation
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

-- actions


-- events
m:lwt('/lwt/' .. MQTT_CLIENTID, "died", 0, 0)

m:on('connect', function(m)
	print('MQTT : ' .. MQTT_CLIENTID .. " connected to : " .. MQTT_HOST .. " on port : " .. MQTT_PORT)
	m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0, function (m)
		print('MQTT : subscribed to ', MQTT_MAINTOPIC) 
	end)

    tmr.alarm(PUBLISH_ALARM_ID, 10000, 1, function ()
        LedBlink(50)
        
        --publish temperatures
        for id,temp in pairs(temperature) do 
            if id ~= nil then
                local str
                if (temp ~= 85.0) then
                    str = string.format("%0.1f", temp)
                else
                    str = "break"
                end
                m:publish("/"..MQTT_CLIENTID.."/state/temp/"..id, str, 0, 0, nil)
            end
        end
        
        --publish humidity data
        if (dhttemp ~= nil) then
            local str = string.format("%0.1f", dhttemp)
            m:publish("/"..MQTT_CLIENTID.."/state/dht/temp", str, 0, 0, nil)
        end
        if (dhthumi ~= nil) then
            local str = string.format("%d", dhthumi)
            m:publish("/"..MQTT_CLIENTID.."/state/dht/humi", str, 0, 0, nil)
        end

        --publish service data
        if (service_cnt < SERVICE_PERIOD / PUBLISH_PERIOD) then
            service_cnt = service_cnt + 1
        else
            service_cnt = 0
            time = tmr.time()
            dd = time / (3600 * 24) 
            hh = (time / 3600) % 24
            mm = (time / 60) % 60
            local str = string.format("%dd %dh %dm", dd, hh, mm)
            --print("Uptime: "..str)
            m:publish("/"..MQTT_CLIENTID.."/state/uptime", str, 0, 1, nil)
            m:publish("/"..MQTT_CLIENTID.."/state/ip", wifi.sta.getip(), 0, 1, nil)
        end
    end)  
end)

m:on('offline', function(m)
	print('MQTT : disconnected from ', MQTT_HOST)
end)

m:on('message', function(m, topic, pl)
	print('MQTT : Topic ', topic, ' with payload ', pl)
	if pl~=nil and dispatcher[topic] then
        LedBlink(50)
		dispatcher[topic](m, pl)
	end
end)


-- Start
dispatcher[MQTT_MAINTOPIC .. '/cmd/dummy'] = dummy
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
