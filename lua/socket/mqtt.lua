-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
m_dis = {}

MQTT_CLIENTID = "socket"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883

-- Standard counter variable. Used for modulo arithmatic
local count = 0
local time = 0

local relay1_pin = 5            --> GPIO14
local relay2_pin = 0            --> GPIO16

gpio.mode(relay1_pin, gpio.OUTPUT)
gpio.write(relay1_pin, gpio.HIGH)

gpio.mode(relay2_pin, gpio.OUTPUT)
gpio.write(relay2_pin, gpio.HIGH)

tmr.stop(2)

function relay1(m, pl)    
    -- Main option control structure. Pretty gross-looking but it works
    -- Option 0 turns everything off
    if pl == "0" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/socket/stat/relay1/", "OFF", 0, 0,
            function(m) print("LED OFF") end)

        gpio.write(relay1_pin, gpio.HIGH)
        print("Relay1 HIGH")

             
    end
    if pl == "1" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/socket/stat/relay1/", "ON", 0, 0,
            function(m) print("LED ON") end)

        gpio.write(relay1_pin, gpio.LOW)
        print("Relay1 LOW")
        
    end
end

function relay2(m, pl)    
    -- Main option control structure. Pretty gross-looking but it works
    -- Option 0 turns everything off
    if pl == "0" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/socket/stat/relay2/", "OFF", 0, 0,
            function(m) print("LED OFF") end)

        gpio.write(relay2_pin, gpio.HIGH)
        print("Relay2 HIGH")

             
    end
    if pl == "1" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/socket/stat/relay2/", "ON", 0, 0,
            function(m) print("LED ON") end)

        gpio.write(relay2_pin, gpio.LOW)
        print("Relay2 LOW")
        
    end
end

-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["/socket/cmd/relay1"] = relay1
m_dis["/socket/cmd/relay2"] = relay2

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
    m:subscribe("/socket/cmd/#", 0,
        function(m) print("Subscribed to CMD Topic") end)

    tmr.alarm(2, 1000, 1, function ()
            time = time + 1
            m:publish("/socket/stat/uptime", time, 0, 0,
            function(m) print("Sent:" .. time) end)
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

