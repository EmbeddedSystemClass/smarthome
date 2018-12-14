-- Variables 
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin

function init_OLED(sda,scl) --Set up the u8glib lib
     id = 0
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g2.ssd1306_i2c_128x64_noname(id, sla)
     disp:setFont(u8g2.font_6x10_tf)
     disp:setFontRefHeightExtendedText()
     --disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     --disp:setRot180()           -- Rotate Display if needed
end

function init_OLED2() --Set up the u8glib lib
   cs  = 8 -- GPIO15
   dc  = 4 -- GPIO2
   res = 0 -- GPIO16
   bus = 1
   spi.setup(bus, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
   -- we won't be using the HSPI /CS line, so disable it again
   gpio.mode(8, gpio.INPUT, gpio.PULLUP)
   disp = u8g2.ssd1306_128x64_noname(bus, cs, dc, res)
end

function print_OLED()
   disp:firstPage()
   repeat
     disp:drawFrame(2,2,126,62)
     disp:drawStr(5, 10, str1)
     disp:drawStr(5, 20, str2)
     disp:drawCircle(18, 47, 14)
   until disp:nextPage() == false
end

function print_OLED2()
    disp:drawFrame(2,2,126,62)
    disp:drawStr(5, 10, str1)
    disp:drawStr(5, 20, str2)
    disp:drawCircle(18, 47, 14)
    disp:sendBuffer()
 end


-- Main Program 
str1="    Hello World!!"
str2="     @kayakpete"
init_OLED2()
print_OLED2() 
