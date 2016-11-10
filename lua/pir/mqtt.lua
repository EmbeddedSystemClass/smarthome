MQTT_CLIENTID = "pir"
MQTT_HOST = "192.168.1.206"
MQTT_PORT = 1883

local pin = 2    --> GPIO4

gpio.mode(pin, gpio.INT, gpio.PULLUP)


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
--    m:subscribe("/socket/cmd/#", 0,
--        function(m) print("Subscribed to CMD Topic") end)

    
    gpio.trig(pin, 'both',  function ()
            data = gpio.read(pin)
            m:publish("/pir/stat/motion", data, 0, 0,
            function(m) print("Motion:" .. data) end)
    end)
       
end)


-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
    print ("\n\nDisconnected from broker")
    print("Heap: ", node.heap())
end)


print("Connecting to: ", MQTT_HOST)
-- Connect to the broker
print(m:connect(MQTT_HOST, MQTT_PORT, 0, 1))
--m:close()

