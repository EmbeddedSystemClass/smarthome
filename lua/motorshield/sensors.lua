
local handlers = {}


function int_print(level, when, eventcount)
     print("level: " .. level)
     print("when: " .. when)
     print("eventcount: " .. eventcount)
end

function right(level, when, eventcount)
     print("right")
end

function left(level, when, eventcount)
     print("left")
end

function center(level, when, eventcount)
     print("center")
end

--handlers
handlers[GPIO5]  = right
handlers[GPIO4]  = center
handlers[GPIO0]  = left

print("Init inputs: ")
for p, h in pairs(handlers) do
    print("pin: " .. p)
    gpio.mode(p, gpio.INT)
    gpio.trig(p, "up", h)
end

