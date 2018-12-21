local FONT_HEIGHT = 10

ALIGN_LEFT = 0
ALIGN_CENTER = 1
ALIGN_RIGHT = 2

local HASHTAG = "#RotekCristmasTree"

local x = 0
local y = 16
local step_x = 1
local step_y = 1

local anim_tmr = tmr.create()


-- setup SPI and connect display
local function init_spi_display()
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

local function split(str, sep)
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

function clear_display()
   disp:clearBuffer()
   disp:sendBuffer()
end

function print_row(row, str, align)
   local x_pos = 0
   if align == ALIGN_RIGHT then
      x_pos = 128 - disp:getUTF8Width(str)
   elseif align == ALIGN_CENTER then
      x_pos = (128 - disp:getUTF8Width(str)) / 2
   end
   if x_pos < 0 then
      x_pos = 0
   end
   disp:drawStr(x_pos, row * FONT_HEIGHT, str)
   disp:sendBuffer()
end

function print_message(str, meta)
   anim_tmr:stop()
   disp:clearBuffer()
   local user = (split(str, ":")[1])
   disp:drawUTF8(0, 0, user)
   disp:drawUTF8(128 - disp:getUTF8Width(meta), 0, meta)
   --Remove username
   local text = string.gsub(str, user .. ":", "")
   --Remove trailing space
   text = string.gsub(text, "^%s*", "")
   disp:drawUTF8(0, 16, text)
   disp:sendBuffer()
end

local function u8g2_prepare()
   disp:setFont(u8g2.font_haxrcorp4089_t_cyrillic)
   disp:setFontRefHeightExtendedText()
   disp:setDrawColor(1)
   disp:setFontPosTop()
   disp:setFontDirection(0)
end

local function print_logo(x_pos, y_pos)
   disp:clearBuffer()
   disp:drawStr((128 - disp:getUTF8Width(HASHTAG)) / 2, 0, HASHTAG)
   disp:drawStr(x_pos, y_pos, "Tweet Me!")
   disp:sendBuffer()
end

local function animation_loop()
   print_logo(x, y)
   
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
 
   anim_tmr:start()
end

function animation_start()
   anim_tmr:start()
end

function animation_stop()
   anim_tmr:stop()
end


anim_tmr:register(50, tmr.ALARM_SEMI, animation_loop)

init_spi_display()
u8g2_prepare()