local PUBLISH_PERIOD = 5 * 1000
local SERVICE_PERIOD = 60 * 1000
local pub_tmr = tmr.create()
local service_tmr = tmr.create()
local temperature = {}

local gas = require("mq135")
local moving_average = require("filter")
local fs = require("fs")

local filter = moving_average(10)

-- Holds keys and callbacks to different topics
local m_dis = {}


-- initialize mqtt client with keepalive timer of 60sec
if m == nil then
    m = mqtt.Client(MQTT_CLIENTID, 60, MQTT_USERNAME, MQTT_PASSWORD) 
else
    m:close()
end

-- events
m:lwt('/lwt/' .. MQTT_CLIENTID, "died", 0, 0)

-- Publish service data: uptime, IP, rssi
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

function get_sensor_id(addr)
    return ('%02X%02X%02X'):format(addr:byte(6,8))
end

local calib_tmr
local calib_flt
local calib_cnt = 0


function calibrate(m, pl)
    run_calib(tonumber(pl))
end

-- Start calibration procedure
function run_calib(sec)
    calib_tmr = tmr.create()
    calib_flt = moving_average(sec)
    local rzero
    
    tmr.register(calib_tmr, 1000, tmr.ALARM_AUTO, function (t)
        if sec > 0 then
            rzero = calib_flt:get_value(gas.get_rzero())
            sec = sec - 1
            print("Calibrating (" .. sec .. "): " .. rzero)
        else
            print("Done: rzero = " .. rzero)
            gas.set_rzero(rzero)
            fs.save_value("rzero.txt", rzero)
            tmr.unregister(calib_tmr)
            calib_tmr = nil
            
            local str = string.format("%f", rzero)
            m:publish("/"..MQTT_CLIENTID.."/state/gas/rzero", str, 0, 1, nil)
        end
    end)

    tmr.start(calib_tmr)
end

 --Publish measurements
function pub()
    local str
 
    LedBlink(50)

    --get temperature
    ds18b20.read(
        function(ind,rom,res,temp,tdec,par)
            temperature[get_sensor_id(rom)] = temp
        end,
    {});
    
    --publish temperature data
    if temperature ~= nil then
        for id,temp in pairs(temperature) do 
            if id ~= nil then
                if (temp ~= 85.0) then
                    str = string.format("%0.1f", temp)
                else
                    str = "break"
                end
                m:publish("/"..MQTT_CLIENTID.."/state/temp/"..id, str, 0, 0, nil)
            end
        end
    end

    --publish CO2 data
    local str = string.format("%0.2f", gas.get_ppm())
    print("ppm:", str)
    m:publish("/"..MQTT_CLIENTID.."/state/gas/ppm", str, 0, 0, nil)

    local str = string.format("%0.2f", filter:get_value(gas.get_ppm()))
    print("fppm:", str)
    m:publish("/"..MQTT_CLIENTID.."/state/gas/fppm", str, 0, 0, nil)

    local str = string.format("%0.3f", gas.get_volt())
    m:publish("/"..MQTT_CLIENTID.."/state/gas/volt", str, 0, 0, nil)
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
    pub()
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


ds18b20.setup(GPIO_ONEWIRE)

-- Init calibration coefs
local rzero = fs.init_value("rzero.txt", nil)
if rzero ~= nil then
    print("mq135: rzero = " .. rzero)
    gas.set_rzero(rzero)
else 
    fs.save_value("rzero.txt", gas.get_rzero())
end

m_dis[MQTT_MAINTOPIC .. '/cmd/calibrate'] = calibrate

-- Connect to the broker
do_mqtt_connect()
