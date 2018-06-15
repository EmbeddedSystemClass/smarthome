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

-- Publish service data: uptime and IP
function service_pub()
    time = tmr.time()
    dd = time / (3600 * 24)
    hh = (time / 3600) % 24
    mm = (time / 60) % 60
    local str = string.format("%dd %dh %dm", dd, hh, mm)
    --print(str)
    --m:publish("/"..MQTT_CLIENTID.."/stat/uptime", str, 0, 1, nil)
    ip = wifi.sta.getip()
    if ip == nil then
        ip = "unknown"
    end
    m:publish("/"..MQTT_CLIENTID.."/stat/ip", ip, 0, 1, nil)
end

function publish()
    if connected == true then
        LedBlink(50)

        --publish battery state
        local str = string.format("%0.2f", bat.get_volt())
        m:publish("/"..MQTT_CLIENTID.."/state/bat/volt", str, 0, 0, nil)
        local str = string.format("%d", bat.get_level())
        m:publish("/"..MQTT_CLIENTID.."/state/bat/level", str, 0, 0, nil)
        local str = string.format("%d", bat.get_raw())
        m:publish("/"..MQTT_CLIENTID.."/state/bat/raw", str, 0, 0, nil)
    
        --publish service data
        if (service_cnt < SERVICE_PERIOD / PUBLISH_PERIOD) then
            service_cnt = service_cnt + 1
        else
            service_cnt = 0
            service_pub()
        end
    end
end

-- When client connects, print status message and subscribe to cmd topic
function handle_mqtt_connect(m)
    -- Serial status message
    print("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
        " on port ", MQTT_PORT, "\n\n")

    -- Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0,
        function(m) print("Subscribed to CMD Topic") end)

    connected = true
    LedFlickerStop()

    --Send all data
    publish()

    --Delayed deepsleep to be able to send publish messages
    tmr.alarm(PUBLISH_ALARM_ID, 1000, 1, function ()
        node.dsleep(60 * 60 * 1000 * 1000)
        --publish()
    end)
end

-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    connected = false
    print ("\n\nDisconnected from broker")
    LedFlicker(1000, 2000, UNLIM_FLICK)
    print("Heap: ", node.heap())
    tmr.unregister(PUBLISH_ALARM_ID)
    do_mqtt_connect()
end)

m:on('message', function(m, topic, pl)
	print('MQTT : Topic ', topic, ' with payload ', pl)
	if pl~=nil and dispatcher[topic] then
        LedBlink(50)
		dispatcher[topic](m, pl)
	end
end)

-- MQTT error handler
function handle_mqtt_error(client, reason)
    tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

-- MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker", MQTT_HOST, "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

-- Connect to the broker
do_mqtt_connect()