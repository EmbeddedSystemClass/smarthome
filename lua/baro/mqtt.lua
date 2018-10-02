local PUBLISH_PERIOD = 10 * 1000
local SERVICE_PERIOD = 60 * 1000
local MQTT_KEEPALIVE = 60
local ALT = 320

local pub_tmr = tmr.create()
local service_tmr = tmr.create()
local online = false

local m_dis = {}

--Optimization magic
local bme280 = bme280
local mqtt = mqtt
local tmr = tmr
local wifi = wifi
local i2c = i2c


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
function pub()
    LedBlink(50)
    
    --Tmperature
    if (temp ~= nil) then
        local str = string.format("%0.1f", temp)
        m:publish("/"..MQTT_CLIENTID.."/state/temp", str, 0, 0, nil)
    end

    --bme280
    T, P, H, QNH = bme280.read(ALT)
    
    if T ~= nil and P ~= nil and H ~= nil and QNH ~= nil then 
        local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
        print(string.format("T=%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100))
        print(string.format("QFE=%d.%03d", P/1000, P%1000))
        print(string.format("QNH=%d.%03d", QNH/1000, QNH%1000))
        print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
        D = bme280.dewpoint(H, T)
        local Dsgn = (D < 0 and -1 or 1); D = Dsgn*D
        print(string.format("dew_point=%s%d.%02d", Dsgn<0 and "-" or "", D/100, D%100))
    end

    -- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
    P = bme280.baro()
    if P ~= nil and QNH ~= nil then
        curAlt = bme280.altitude(P, QNH)
        local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
        print(string.format("altitude=%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100))
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
    pub()

    tmr.alarm(service_tmr, SERVICE_PERIOD, tmr.ALARM_AUTO, service_pub)
    tmr.start(service_tmr)

    tmr.alarm(pub_tmr, PUBLISH_PERIOD, tmr.ALARM_AUTO, pub)
    tmr.start(pub_tmr)
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
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

--MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker " .. MQTT_HOST ..  "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

--Assign MQTT handlers
m_dis[MQTT_MAINTOPIC .. '/cmd/dummy'] = dummy

--Init bme280
i2c.setup(0, GPIO_SDA, GPIO_SCL, i2c.SLOW) -- call i2c.setup() only once
print(bme280.setup())

--Connect to the broker
do_mqtt_connect()
