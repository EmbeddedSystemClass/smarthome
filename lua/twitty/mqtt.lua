local PUBLISH_PERIOD = 10 * 1000
local SERVICE_PERIOD = 60 * 1000
local MQTT_KEEPALIVE = 60
local LOOP_PERIOD = 5 * 1000
local MAX_TWEETS_COUNT = 30

local pub_tmr = tmr.create()
local service_tmr = tmr.create()

loop_tmr = tmr.create()

local online = false

local m_dis = {}

local fs = require "fs"

--Restore write index
local w_ind = fs.read_value("w_ind")
if w_ind == nil then
    w_ind = 1
else
    w_ind =  tonumber(w_ind)
end

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
local function service_pub()
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


 --Print tweet
 local function print_msg(m, pl)
    --Reset main loop
    tmr.start(loop_tmr)

    --Store received tweet
    if w_ind > MAX_TWEETS_COUNT then
        w_ind = 1
    end
    fs.write_tweet(w_ind, pl)

    print_message(pl, w_ind .. "/" .. MAX_TWEETS_COUNT)

    if online then
        m:publish(MQTT_MAINTOPIC .. '/echo', pl, 0, 0)
        print("MQTT (online): " .. pl)
        LedBlink(100)
    else
        print("MQTT (offline): " .. pl)
    end

    w_ind = w_ind + 1
    fs.write_value("w_ind", w_ind)
end


--Tweets erase
local function erase(m, pl)
    tmr.stop(loop_tmr)
    if pl == "all" then
        fs.erase_all(MAX_TWEETS_COUNT)
        w_ind = 1
        r_ind = 1
        fs.write_value("w_ind", w_ind)
        print("Erased all")
    else
        local num = tonumber(pl)
        if num ~= nil then
            fs.erase_tweet(num)
            print("Erased tweet " .. num)
        end
    end
    tmr.start(loop_tmr)
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

    animation_start()
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


local r_ind = 1
local animation = true

function loop()
    local timeout = LOOP_PERIOD

    if r_ind > MAX_TWEETS_COUNT then
        r_ind = 1
    end

    if r_ind >= 5 and r_ind % 5 == 0 and animation == true then
        animation_start()
        animation = false
        tmr.interval(loop_tmr, timeout)
        tmr.start(loop_tmr)
        return
    end

    local tweet = fs.read_tweet(r_ind)
    if tweet ~= nil then
        print_message(tweet, r_ind .. "/" .. MAX_TWEETS_COUNT)
        timeout = disp:getUTF8Width(tweet) * 50
        if timeout < 3000 then
            timeout = 3000
        elseif timeout > 6000 then
            timeout = 6000
        end
        animation = true
        r_ind = r_ind + 1
    else
        if r_ind < 5 then
            animation = true
        else
            animation = false
        end
        timeout = 10
        r_ind = r_ind + 1
    end
    tmr.interval(loop_tmr, timeout)
    tmr.start(loop_tmr)
end


--Assign MQTT handlers
m_dis[MQTT_MAINTOPIC .. '/cmd/display'] = print_msg
m_dis[MQTT_MAINTOPIC .. '/cmd/erase'] = erase


tmr.alarm(loop_tmr, LOOP_PERIOD, tmr.ALARM_SEMI, loop)

--Connect to the broker
do_mqtt_connect()
