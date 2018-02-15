dofile("gpio.lua")

local handlers = {}
local states = {}
local names = {}

--GPIO names
names[GPIO16] = "GPIO16"
names[GPIO5]  = "GPIO5"
names[GPIO4]  = "GPIO4"
names[GPIO0]  = "GPIO0"
names[GPIO2]  = "GPIO2"
names[GPIO14] = "GPIO14"
names[GPIO12] = "GPIO12"
names[GPIO13] = "GPIO13"
names[GPIO15] = "GPIO15"

-- debounce
function debounce(func)
    local last = 0

    return function (...)
        local now = tmr.now()
        if now - last < BUTTON_DEBOUNCE then return end

        last = now
        return func(...)
    end
end

function inputs_init()
    for pin, h in pairs(handlers) do
            --print("init " .. pin)
            --initial trigger states
            states[pin] = 1
            gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
    end
    print("Inputs initialized")
end

function inputs_poll()
    --print("---")
    for pin, handle in pairs(handlers) do
        --debug output
        --gpio_print(pin)
        
        trigged, state = gpio_trig(pin)
        if trigged then
            --debug output
            --print("Event: "..names[pin].."(D"..pin..") = "..state)
            
            handlers[pin](pin, state)
        end
    end
end

function gpio_print(pin)
    print(names[pin].."(D"..pin..") = "..gpio.read(pin))
end

function gpio_trig(pin)
    state = gpio.read(pin)
    if state ~= states[pin] then
        states[pin] = state
        return true, state
    else
        return false, state
    end
end

--handlers
handlers[GPIO4]  = gpio_print
handlers[GPIO0]  = gpio_print
handlers[GPIO13] = gpio_print

--init GPIOs
inputs_init()

tmr.alarm(INPUTS_ALARM_ID, INPUTS_POLL_DELAY, tmr.ALARM_AUTO, inputs_poll)
