local servo = require "servo"
local motor = require "motor"

-- Holds dispatching keys to different topics. Serves as a makeshift callback
-- function dispatcher based on topic and message content
m_dis = {}

MQTT_CLIENTID = "motor"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883

-- Standard counter variable. Used for modulo arithmatic
local count = 0
local time = 0


function run_forward(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "forward " .. pl, 0, 0,
            function(m) print("run: forward" .. pl) end)
    
    motor.set("A", "F", pl)
    motor.set("B", "F", pl)
end


function run_backward(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "backward " .. pl, 0, 0,
            function(m) print("run: backward" .. pl) end)
    
    motor.set("A", "R", pl)
    motor.set("B", "R", pl)
end


function turn_left(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "left " .. pl, 0, 0,
            function(m) print("run: left" .. pl) end)
    
    motor.set("A", "F", pl)
    motor.set("B", "R", pl)
end


function turn_right(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "right " .. pl, 0, 0,
            function(m) print("run: right" .. pl) end)
    
    motor.set("A", "B", pl)
    motor.set("B", "F", pl)
end


function stop(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "stop", 0, 0,
            function(m) print("stop") end)
    
    motor.set("A", "R", 0)
    motor.set("B", "R", 0)
end


function light(m, pl)
    if pl == "0" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/motor/stat/light", "OFF", 0, 0,
            function(m) print("Light OFF") end)
        --gpio.write(light_pin, gpio.HIGH)    
    end
    if pl == "1" then
        -- Confirm LED being turned off to serial terminal and MQTT broker
        m:publish("/motor/stat/light", "ON", 0, 0,
            function(m) print("Light ON") end)
        --gpio.write(light_pin, gpio.LOW)
    end
end


function move_servo(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/servo", "servo: " .. pl, 0, 0,
            function(m) print("servo: " .. pl) end)

    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
    servo.set(tonumber(args[1]),tonumber(args[2]))
end

    
-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["/motor/cmd/forward"] = run_forward
m_dis["/motor/cmd/backward"] = run_backward
m_dis["/motor/cmd/left"] = turn_left
m_dis["/motor/cmd/right"] = turn_right
m_dis["/motor/cmd/stop"] = stop
m_dis["/motor/cmd/light"] = light
m_dis["/motor/cmd/servo"] = move_servo


-- initialize mqtt client with keepalive timer of 60sec
m = mqtt.Client(MQTT_CLIENTID, 60, "", "") -- Living dangerously. No password!


-- Set up Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "Oh noes! Plz! I don't wanna die!", 0, 0)


-- When client connects, print status message and subscribe to cmd topic
m:on("connect", function(m) 
    -- Serial status message
    print ("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
        " on port ", MQTT_PORT, "\n\n")

    -- Subscribe to the topic where the ESP8266 will get commands from
    m:subscribe("/motor/cmd/#", 0,
        function(m) print("Subscribed to CMD Topic") end)
        
end)


-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
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

print("Connecting to: ", MQTT_HOST)
-- Connect to the broker
print(m:connect(MQTT_HOST, MQTT_PORT, 0, 1))
--m:close()

