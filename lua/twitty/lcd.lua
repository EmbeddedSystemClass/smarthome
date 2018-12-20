local FONT_HEIGHT = 10

local x = 0
local y = 16
local step_x = 1
local step_y = 1


-- setup SPI and connect display
function init_spi_display()
   -- Hardware SPI CLK  = GPIO14
   -- Hardware SPI MOSI = GPIO13
   -- Hardware SPI MISO = GPIO12 (not used)
   -- Hardware SPI /CS  = GPIO15 (not used)
   -- CS, D/C, and RES can be assigned freely to available GPIOs
   local cs  = 8 -- GPIO15, pull-down 10k to GND
   local dc  = 4 -- GPIO2
   local res = 0 -- GPIO16

   spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
   -- we won't be using the HSPI /CS line, so disable it again
   gpio.mode(8, gpio.INPUT, gpio.PULLUP)

   disp = u8g2.ssd1306_128x64_noname(1, cs, dc, res)
end

function split(str, sep)
   if sep == nil then
           sep = "%s"
   end
   local t={} ; i=1
   for str in string.gmatch(str, "([^"..sep.."]+)") do
           t[i] = str
           i = i + 1
   end
   return t
end

function print_display_row(row, str)
   disp:drawStr(0, row * FONT_HEIGHT, str)
   disp:sendBuffer()
end

function print_message(str)
   loop_tmr:stop()
   disp:clearBuffer()
   disp:drawUTF8(0, 0, split(str, ":")[1])
   disp:drawUTF8(0, 16, str)
   disp:sendBuffer()
end

function u8g2_prepare()
   disp:setFont(u8g2.font_6x10_tf)
   disp:setFontRefHeightExtendedText()
   disp:setDrawColor(1)
   disp:setFontPosTop()
   disp:setFontDirection(0)
end

function draw()
   disp:drawStr(0, 0, "#RotekCristmasTree")
   disp:drawStr(x, y, "Tweet Me!")
end

function loop()
   disp:clearBuffer()
   draw()
   disp:sendBuffer()

   x = x + step_x
   y = y + step_y
   
   if x >= 128 - disp:getUTF8Width("Tweet Me!") then
     step_x = -1
   elseif x <= 0 then
      step_x = 1
   end
   if y >= 64 - FONT_HEIGHT then
      step_y = -1
   elseif y <= 16 then
      step_y = 1
   end
 
   loop_tmr:start()
end


loop_tmr = tmr.create()
loop_tmr:register(50, tmr.ALARM_SEMI, loop)

init_spi_display()
u8g2_prepare()
loop_tmr:start()
