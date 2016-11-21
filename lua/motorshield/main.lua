local servo = require "servo"
local motor = require "motor"

servo.set(9, 200)
motor.set("B", "F", 300)

