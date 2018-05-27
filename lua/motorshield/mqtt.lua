local chassis = require "chassis"

-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
m_dis = {}

-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["/motor/cmd/forward"] = chassis.run_forward
m_dis["/motor/cmd/backward"] = chassis.run_backward
m_dis["/motor/cmd/left"] = chassis.turn_left
m_dis["/motor/cmd/right"] = chassis.turn_right
m_dis["/motor/cmd/stop"] = chassis.stop
m_dis["/motor/cmd/light"] = chassis.light
m_dis["/motor/cmd/servo"] = chassis.move_servo


-- initialize mqtt client with keepalive timer of 60sec
m = mqtt.Client(MQTT_CLIENTID, 10, "", "") -- Living dangerously. No password!

-- Set up Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "Oh noes! Plz! I don't wanna die!", 0, 0)

-- Publish service data: uptime and IP
function service_pub()
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

-- When client connects, print status message and subscribe to cmd topic
function handle_mqtt_connect(m)
    -- Serial status message
    print("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
        " on port ", MQTT_PORT, "\n\n")

    -- Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe("/motor/cmd/#", 0,
        function(m) print("Subscribed to CMD Topic") end)

    -- Publish service data periodicaly
    service_pub()
    tmr.alarm(PUBLISH_ALARM_ID, 60000, 1, service_pub)
end

-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
    tmr.unregister(PUBLISH_ALARM_ID)
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
    print("herror")
    tmr.create():alarm(2 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

-- MQTT connect handler
function do_mqtt_connect()
  print("Connecting to broker", MQTT_HOST, "...")
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, handle_mqtt_connect, handle_mqtt_error)
end

-- Connect to the broker
do_mqtt_connect()
