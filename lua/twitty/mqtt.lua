local PUBLISH_PERIOD = 10 * 1000
local SERVICE_PERIOD = 60 * 1000
local MQTT_KEEPALIVE = 60

local pub_tmr = tmr.create()
local service_tmr = tmr.create()
local online = false

local m_dis = {}

--Optimization magic
local mqtt = mqtt
local tmr = tmr
local wifi = wifi


--initialize MQTT client with keepalive timer of 60sec
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

--Set LWT
m:lwt('/lwt/' .. MQTT_CLIENTID, "died", 0, 0)

--Publish service data: uptime, IP, rssi
function service_pub()
    LedBlink(50)
    time = tmr.time()
    dd = time / (3600 * 24)
    hh = (time / 3600) % 24
    mm = (time / 60) % 60
    local str = string.format("%dd %dh %dm", dd, hh, mm)
    m:publish("/"..MQTT_CLIENTID.."/state/uptime", str, 0, 1, nil)
    ip = wifi.sta.getip()
    if ip == nil then
        ip = "unknown"
    end
    rssi = wifi.sta.getrssi()
    if rssi == nil then
        rssi = "unknown"
    end
    m:publish("/"..MQTT_CLIENTID.."/state/ip", ip, 0, 1, nil)
    m:publish("/"..MQTT_CLIENTID.."/state/rssi", rssi, 0, 1, nil)
end

 --Publish measurements
function print_msg(m, pl)
    
    --TODO print on LCD
    print("Message: " .. pl)

    if online then
        m:publish(MQTT_MAINTOPIC .. '/echo', pl, 0, 1)
        print("MQTT (online): " .. pl)
        LedBlink(100)
    else
        print("MQTT (offline): " .. pl)
    end
end

--When client connects, print status message and subscribe to cmd topic
function handle_mqtt_connect(m)
    --Set connection status flag
    online = true

    --Serial status message
    print("MQTT: " .. MQTT_CLIENTID .. " connected to broker " 
        .. MQTT_HOST .. ":" .. MQTT_PORT)

    --Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe(MQTT_MAINTOPIC .. '/cmd/#', 0, function (m)
        print('MQTT: subscribed to ' .. MQTT_MAINTOPIC) 
    end)

    service_pub()

    tmr.alarm(service_tmr, SERVICE_PERIOD, tmr.ALARM_AUTO, service_pub)
    tmr.start(service_tmr)
end

--When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    --Clear connection status flag
    online = false

    --Try to reconnect
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
    tmr.stop(service_tmr)
    do_mqtt_connect()
end)

--Interpret the command
m:on("message", function(m,t,pl)
    print("PAYLOAD: ", pl)
    print("TOPIC: ", t)
    
    --Run command handler
    if pl~=nil and m_dis[t] then
        m_dis[t](m,pl)
    end
end)

--MQTT error handler
function handle_mqtt_error(client, reason)
    LedFlicker(50, 200, 5)
    print("Reason: ", reason)
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

--MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker " .. MQTT_HOST ..  "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

--Assign MQTT handlers
m_dis[MQTT_MAINTOPIC .. '/cmd/display'] = print_msg


--Connect to the broker
do_mqtt_connect()