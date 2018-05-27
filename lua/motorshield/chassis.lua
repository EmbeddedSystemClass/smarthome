local chassis = {}
local servo = require "servo"
local motor = require "motor"


function chassis.run_forward(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "forward " .. pl, 0, 0,
            function(m) print("run: forward" .. pl) end)
    
    motor.set("A", "F", pl)
    motor.set("B", "F", pl)
end


function chassis.run_backward(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "backward " .. pl, 0, 0,
            function(m) print("run: backward" .. pl) end)
    
    motor.set("A", "R", pl)
    motor.set("B", "R", pl)
end


function chassis.turn_left(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "left " .. pl, 0, 0,
            function(m) print("run: left" .. pl) end)
    
    motor.set("A", "F", pl)
    motor.set("B", "R", pl)
end


function chassis.turn_right(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "right " .. pl, 0, 0,
            function(m) print("run: right" .. pl) end)
    
    motor.set("A", "R", pl)
    motor.set("B", "F", pl)
end


function chassis.stop(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/run", "stop", 0, 0,
            function(m) print("stop") end)
    
    motor.set("A", "R", 0)
    motor.set("B", "R", 0)
end


function chassis.light(m, pl)
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


function chassis.move_servo(m, pl)
    -- Confirm that an animation message was received on the /mcu/cmd topic
    m:publish("/motor/stat/servo", "servo: " .. pl, 0, 0,
            function(m) print("servo: " .. pl) end)

    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
    servo.set(tonumber(args[1]),tonumber(args[2]))
end

return chassis