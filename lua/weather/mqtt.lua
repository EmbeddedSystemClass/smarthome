local PUBLISH_PERIOD = 10 * 1000
local SERVICE_PERIOD = 60 * 1000
local pub_tmr = tmr.create()
local service_tmr = tmr.create()

-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
local m_dis = {}

-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis[MQTT_MAINTOPIC .. '/cmd/dummy'] = dummy

-- initialize mqtt client with keepalive timer of 60sec
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

-- events
m:lwt('/lwt/' .. MQTT_CLIENTID, "died", 0, 0)

-- Publish service data: uptime and IP
function service_pub()
    LedBlink(50)
    time = tmr.time()
    dd = time / (3600 * 24)
    hh = (time / 3600) % 24
    mm = (time / 60) % 60
    local str = string.format("%dd %dh %dm", dd, hh, mm)
    --print(str)
    m:publish("/"..MQTT_CLIENTID.."/stat/uptime", str, 0, 1, nil)
    ip = wifi.sta.getip()
    if ip == nil then
        ip = "unknown"
    end
    m:publish("/"..MQTT_CLIENTID.."/stat/ip", ip, 0, 1, nil)
end

 --Publish measurements
function pub()
    LedBlink(50)

    --publish temperature data
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
end

-- When client connects, print status message and subscribe to cmd topic
function handle_mqtt_connect(m)
    -- Serial status message
    print("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
        " on port ", MQTT_PORT, "\n\n")

    -- Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0, function (m)
        print('MQTT : subscribed to ', MQTT_MAINTOPIC) 
    end)

    -- Publish service data periodicaly
    service_pub()
    tmr.alarm(service_tmr, SERVICE_PERIOD, tmr.ALARM_AUTO, service_pub)
    tmr.alarm(pub_tmr, PUBLISH_PERIOD, tmr.ALARM_AUTO, pub)
    tmr.start(service_tmr)
    tmr.start(pub_tmr)
end

-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
    tmr.stop(pub_tmr)
    tmr.stop(service_tmr)
    do_mqtt_connect()
end)

-- On a publish message receive event, run the message dispatcher and
-- interpret the command
m:on("message", function(m,t,pl)
    print("PAYLOAD: ", pl)
    print("TOPIC: ", t)
    
    -- This is like client.message_callback_add() in the Paho python client.
    -- It allows different functions to be run based on the message topic
    if pl~=nil and m_dis[t] then
        m_dis[t](m,pl)
    end
end)

-- MQTT error handler
function handle_mqtt_error(client, reason)
    LedFlicker(50, 200, 5)
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

-- MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker", MQTT_HOST, "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

-- Connect to the broker
do_mqtt_connect()
