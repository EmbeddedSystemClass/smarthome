local PUBLISH_PERIOD = 10 * 1000
local SERVICE_PERIOD = 60 * 1000
local pub_tmr = tmr.create()
local service_tmr = tmr.create()
local pump_timeout = 0

-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
local m_dis = {}

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
    tmr.start(service_tmr)
end

-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
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


local function pump_off(m)
    gpio.write(GPIO_SWITCH, gpio.LOW)
    m:publish(MQTT_MAINTOPIC .. '/state/pump', "0", 0, 1)
end

local function pump_on(m)
    gpio.write(GPIO_SWITCH, gpio.HIGH)
    m:publish(MQTT_MAINTOPIC .. '/state/pump', "1", 0, 1)
end

local function stop(m)
    pump_off(m)
    tmr.stop(PUMP_ALARM_ID)
    pump_timeout = 0
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
local function switch_power(m, pl)
    if pl == "ON" or pl == "1" then
        gpio.write(GPIO_SWITCH, gpio.HIGH)
        print("MQTT : plug ON for ", MQTT_CLIENTID)
    elseif pl == "OFF" or pl == "0" then
        gpio.write(GPIO_SWITCH, gpio.LOW)
        print("MQTT : plug OFF for ", MQTT_CLIENTID)
    end
end

local function toggle_power()
    LedBlink(100)
    if gpio.read(GPIO_SWITCH) == gpio.HIGH then
        pump_off()
    else
        pump_on()
    end
end

local function fill_tank(m, pl)
    local PUMP_TIMEOUT = tonumber(pl)
    LedBlink(100)
    if IsFlood() then
        pump_off(m)
    else
        pump_on(m)
        tmr.alarm(PUMP_ALARM_ID, 1000, tmr.ALARM_AUTO, function()
            if IsFlood() or pump_timeout >= PUMP_TIMEOUT then
                pump_off(m)
                tmr.stop(PUMP_ALARM_ID)
                pump_timeout = 0
            else
                pump_timeout = pump_timeout + 1
            end
        end)
    end
end


--Init GPIOs
gpio.mode(GPIO_SWITCH, gpio.OUTPUT)
gpio.mode(GPIO_BUTTON, gpio.INT)
gpio.trig(GPIO_BUTTON, 'down', debounce(toggle_power))

-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis[MQTT_MAINTOPIC .. '/cmd/power'] = switch_power
m_dis[MQTT_MAINTOPIC .. '/cmd/stop'] = stop
m_dis[MQTT_MAINTOPIC .. '/cmd/filltank'] = fill_tank

-- Connect to the broker
do_mqtt_connect()
