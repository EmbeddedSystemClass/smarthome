local servo = require "servo"
local SERVICE_PERIOD = 60 * 1000
local service_tmr = tmr.create()
require "runtime"
require "trimmer"

local delta = 32 

btn_vals = {13, 254, 465, 648, 811}
btn_valves = pins

local pump_pin = 0
local pump_timer = tmr.create()

local servo_en = 7

-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
m_dis = {}

-- Standard counter variable. Used for modulo arithmatic
local count = 0
local time = 0

-- Use remote controlled pump or local controlled pump
local use_remote_pump = false


-- Init ADC
adc.force_init_mode(adc.INIT_ADC)

gpio.mode(servo_en, gpio.OUTPUT)
gpio.write(servo_en, gpio.HIGH) 

gpio.mode(pump_pin, gpio.OUTPUT)
gpio.write(pump_pin, gpio.LOW) 


function pump_run()
    if use_remote_pump then
        m:publish("/socket2/cmd/relay1", "1", 0, 0,
            function(m) print("relay1 - ON") end)
    else
        gpio.write(pump_pin, gpio.HIGH)
    end
end

function pump_stop()
    if use_remote_pump then
        m:publish("/socket2/cmd/relay1", "0", 0, 0,
            function(m) print("relay1 - OFF") end)
    else
        gpio.write(pump_pin, gpio.LOW)
    end
end

function check_btn(val, btn)
    if val > btn - delta and val < btn + delta then
        return true
    else
        return false
    end
end



function set_trimmer_closed(m, pl)
    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
    valves_closed[tonumber(args[1])] = tonumber(args[2])
    save_trimmer()
end

function set_trimmer_opened(m, pl)
    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
    valves_opened[tonumber(args[1])] = tonumber(args[2])
    save_trimmer()
end


   
function switch_valve(valve)
    if valves_states[valve] then 
        servo.set(btn_valves[valve], valves_closed[valve])
        valves_states[valve] = false
        pump_stop() 
    else
        servo.set(btn_valves[valve], valves_opened[valve])
        valves_states[valve] = true
        pump_run()
    end    
end

function close_all()
    for i, valve in pairs(btn_valves) do
        print(i, valve)
        servo.set(valve, valves_closed[i])
        valves_states[i] = false
    end
end

init_trimmer()
init_timer()


tmr.register(pump_timer, 5000, tmr.ALARM_SEMI, function (t) 
    print("Stop pump")
    stop(m)
    end)

-- Buttons polling (ADC)
tmr.alarm(5, 100, 1, function ()
    val = adc.read(0)
    if     check_btn(val, btn_vals[1]) and release then
        print ("btn1")
        switch_valve(1)
        release = false
    elseif check_btn(val, btn_vals[2]) and release then
        print ("btn2")
        switch_valve(2)
        release = falseset_time
    elseif check_btn(val, btn_vals[3]) and release then
        print ("btn3")
        switch_valve(3)
        release = false
    elseif check_btn(val, btn_vals[4]) and release then
        print ("btn4")
        switch_valve(4)
        release = false
    elseif check_btn(val, btn_vals[5]) and release then
        print ("btn5")
        switch_valve(5)
        release = false
    elseif val > 1000 then
        release = true
    end
end)


function move_servo(m, pl)
    -- Confirm
    m:publish("/water/state/servo", "servo: " .. pl, 0, 0,
            function(m) print("servo: " .. pl) end)

    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
      servo.set(tonumber(args[1]),tonumber(args[2]))
end

function set_pump(m, pl)
    m:publish("/water/state/pump", "pump: " .. pl, 0, 0,
            function(m) print("pump: " .. pl) end)
    if pl == "0" then 
        pump_run()
    else
        pump_stop() 
    end
end

function run(m, pl)
    m:publish("/water/state/mode", "run: " .. pl, 0, 0,
            function(m) print("run: " .. pl) end)
    close_all()
    switch_valve(tonumber(pl))
    pump_run()
    int = timers[tonumber(pl)] * 1000
    print("int: " .. int)
    tmr.interval(pump_timer, int) 
    tmr.start(pump_timer)
end

function stop(m)
    --m:publish("/water/state/mode", "stop", 0, 0,
    --        function(m) print("stop") end)
    m:publish("/water/state/status", "0", 0, 0, nil)
    close_all()
    pump_stop()
end
    
-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["/water/cmd/servo"] = move_servo --<valve num>,<position>
m_dis["/water/cmd/pump"] = set_pump --<0/1> - pump state
m_dis["/water/cmd/run"] = run --<valve num>
m_dis["/water/cmd/stop"] = stop --<any payload> - stop all
m_dis["/water/cmd/trim_closed"] = set_trimmer_closed --<valve num>,<pos> - closed valve position
m_dis["/water/cmd/trim_opened"] = set_trimmer_opened --<valve num>,<pos> - opened valve position
m_dis["/water/cmd/time"] = set_timer --<valve num>,<time> - time to run valve


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
    --LedBlink(50)
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
    --LedFlicker(50, 200, 5)
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

-- MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker", MQTT_HOST, "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

-- Connect to the broker
do_mqtt_connect()