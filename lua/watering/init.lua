 
 -- Config
local pin = 4            --> GPIO2
local value = gpio.HIGH

abort = false

-- Initialise the pin
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, value)
-- Initialize PUMP pin
gpio.mode(0, gpio.OUTPUT)
gpio.write(0, gpio.LOW)

local ssid = "Wlan_WP2"
local pass = "Chronion.7"

 function startup()
    if abort == true then
        print('startup aborted')
        return
    end
    abort = true
    -- otherwise, start up
    dofile ("start.lua")
 end
 
 --init.lua
 wifi.setmode(wifi.STATION)
 wifi.sta.config(ssid,pass)
 local n = 10
 wifi.sta.connect()
 tmr.alarm(1, 1000, 1, function()
  if wifi.sta.getip()== nil then 
  gpio.write(pin, gpio.LOW)
  print("IP unavaiable, Waiting...")
  gpio.write(pin, gpio.HIGH)
  n = n - 1
  if n == 0 then 
    tmr.stop(1)
    print("Wi-Fi connection error.")
    dofile ("led.lua")
    end
 else
  tmr.stop(1)
  
 print("ESP8266 mode is: " .. wifi.getmode())
 print("The module MAC address is: " .. wifi.ap.getmac())
 print("Config done, IP is "..wifi.sta.getip())
 dofile ("telnet.lua")
 
 tmr.alarm(1,5000,0,startup)

 end
 end)

 


 
