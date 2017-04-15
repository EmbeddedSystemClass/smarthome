-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
m_dis = {}

MQTT_CLIENTID = "weather"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883

-- Standard counter variable. Used for modulo arithmatic
local count = 0
local time = 0
local state = 0

gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.HIGH)

tmr.stop(2)

pwm.setup(4,1000,1000);
pwm.start(4);

function animate(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/"..MQTT_CLIENTID.."/led/", "--> ANIMATE COMMAND", 0, 0,
            function(m) print("ANIMATE COMMAND") end)
    
    -- Main option control structure. Pretty gross-looking but it works
    -- Option 0 turns everything off
    if pl == "0" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/"..MQTT_CLIENTID.."/led/", "OFF", 0, 0,
            function(m) print("LED OFF") end)

        gpio.write(4, gpio.HIGH)
      
    end
    if pl == "1" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/"..MQTT_CLIENTID.."/led/", "ON", 0, 0,
            function(m) print("LED ON") end)

        gpio.write(4, gpio.LOW)
      
    end
end

function dim(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/"..MQTT_CLIENTID.."/led/", "--> DIM COMMAND", 0, 0,
            function(m) print("DIM COMMAND") end)
   
    if pl ~= nil then
        pwm.setduty(4,1000-pl*10);
    end
end

    
-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["/"..MQTT_CLIENTID.."/cmd/led"] = animate
m_dis["/"..MQTT_CLIENTID.."/cmd/dim"] = dim

-- initialize mqtt client with keepalive timer of 60sec
m = mqtt.Client(MQTT_CLIENTID, 60, "", "") -- Living dangerously. No password!


-- Set up Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
--m:lwt("/lwt", "Oh noes! Plz! I don't wanna die!", 0, 0)


-- When client connects, print status message and subscribe to cmd topic
m:on("connect", function(m) 
    -- Serial status message
    print ("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
        " on port ", MQTT_PORT, "\n\n")

    -- Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe("/"..MQTT_CLIENTID.."/cmd/#", 0,
        function(m) print("Subscribed to CMD Topic") end)

    m:publish("/"..MQTT_CLIENTID.."/stat/ip", wifi.sta.getip(), 0, 0, nil)

    tmr.alarm(2, 60009, 1, function ()
            time = tmr.time()
            dd = time / (3600 * 24) 
            hh = (time / 3600) % 24
            mm = (time / 60) % 60
            local str = string.format("%dd %dh %dm", dd, hh, mm)
            print(str)
            m:publish("/"..MQTT_CLIENTID.."/stat/uptime", str, 0, 0, nil)
            m:publish("/"..MQTT_CLIENTID.."/stat/ip", wifi.sta.getip(), 0, 0, nil)
    end)

    tmr.alarm(5, 10000, 1, function ()
            if (temp ~= nil and state == 0) then
                state = 1;
                local str = string.format("%0.1f", temp)
                m:publish("/"..MQTT_CLIENTID.."/stat/temp", str, 0, 0, nil)
                return
            end
            if (dhttemp ~= nil and state == 1) then
                state = 2
                local str = string.format("%0.1f", dhttemp)
                m:publish("/"..MQTT_CLIENTID.."/stat/dhttemp", str, 0, 0, nil)
                return
            end
            if (dhthumi ~= nil and state == 2) then
                state = 0
                local str = string.format("%d", dhthumi)
                m:publish("/"..MQTT_CLIENTID.."/stat/humi", str, 0, 0, nil)
                return
            end
    end)
        
end)


-- When client disconnects, print a message and list space left on stack
--m:on("offline", function(m)
--    print ("\n\nDisconnected from broker")
--    print("Heap: ", node.heap())
--end)


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

print("Connecting to: ", MQTT_HOST)
-- Connect to the broker
print(m:connect(MQTT_HOST, MQTT_PORT, 0, 1))
--m:close()

