bat = require("battery")

local dispatcher = {}
local connected = false

local PUBLISH_PERIOD = 10000
local SERVICE_PERIOD = PUBLISH_PERIOD * 6
local service_cnt = SERVICE_PERIOD / PUBLISH_PERIOD


-- client activation
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

-- debounce
function debounce(func)
    local last = 0

    return function (...)
        local now = tmr.now()
        if now - last < BUTTON_DEBOUNCE then return end

        last = now
        return func(...)
    end
end

-- actions

-- events
--m:lwt('/lwt', MQTT_CLIENTID .. " died !", 0, 0)

function publish()
    if connected == true then
        LedBlink(50)

        --publish battery state
        local str = string.format("%0.1f", bat.get_volt())
        m:publish("/"..MQTT_CLIENTID.."/state/bat/volt", str, 0, 0, nil)
        local str = string.format("%d%%", bat.get_level())
        m:publish("/"..MQTT_CLIENTID.."/state/bat/level", str, 0, 0, nil)

        --publish service data
        if (service_cnt < SERVICE_PERIOD / PUBLISH_PERIOD) then
            service_cnt = service_cnt + 1
        else
            service_cnt = 0
            time = tmr.time()
            local str = string.format("%d", time)
            --print("Uptime: "..str)
            m:publish("/"..MQTT_CLIENTID.."/state/uptime", str, 0, 1, nil)
            --m:publish("/"..MQTT_CLIENTID.."/state/ip", wifi.sta.getip(), 0, 1, nil)
        end
    end
end

m:on('connect', function(m)
	print('MQTT : ' .. MQTT_CLIENTID .. " connected to : " .. MQTT_HOST .. " on port : " .. MQTT_PORT)
	m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0, function (m)
		print('MQTT : subscribed to ', MQTT_MAINTOPIC) 
	end)

    connected = true
    LedFlickerStop()

    --Send all data
    publish()

    --Delayed deepsleep to be able to send publish messages
    tmr.alarm(PUBLISH_ALARM_ID, 500, 1, function ()
        node.dsleep(60 * 60 * 1000 * 1000)
    end)
end)

m:on('offline', function(m)
    connected = false
    LedFlicker(1000, 2000, UNLIM_FLICK)
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
--dispatcher[MQTT_MAINTOPIC .. '/cmd/power'] = switch_power
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
