sht = require("sht30")

sht.init("sht30", nil)

sht.get_data()


--Publish measurements
function pub()
    print("status", get_status())
    LedBlink(50)
end
